// The update policy of the WordsMap apps: the published releases, checked, and the answer of
// GET /api/app-updates. Plain TypeScript, so Node can test it as it is (npm test).

export const platforms = ["android", "ios"] as const;
export type Platform = (typeof platforms)[number];

export interface Release {
  latestVersion: string;
  latestBuild: number;
  minimumSupportedBuild: number;
  releaseNotes: Record<string, string>;
  storeUrl: string;
}

export type Releases = Record<Platform, Release>;

const storeHosts: Record<Platform, string[]> = {
  android: ["play.google.com"],
  ios: ["apps.apple.com", "itunes.apple.com"],
};

const versionPattern = /^\d{1,9}(\.\d{1,9}){0,3}$/;
const languagePattern = /^[a-z]{2,3}$/;
const releaseKeys = ["latestVersion", "latestBuild", "minimumSupportedBuild", "releaseNotes", "storeUrl"];

/**
 * Checks releases.json. Any mistake is reported, and the Worker then answers with an error
 * instead of passing it on: the apps keep what they knew, and nobody is locked out.
 */
export function checkReleases(value: unknown): { releases: Releases } | { problems: string[] } {
  const problems: string[] = [];
  if (!isObject(value)) return { problems: ["releases must be an object"] };
  for (const key of Object.keys(value)) {
    if (!platforms.includes(key as Platform)) problems.push(`unknown platform "${key}"`);
  }
  for (const platform of platforms) {
    const release = value[platform];
    if (!isObject(release)) {
      problems.push(`${platform}: missing`);
      continue;
    }
    const at = (field: string) => `${platform}.${field}`;
    for (const key of Object.keys(release)) {
      if (!releaseKeys.includes(key)) problems.push(`${at(key)}: unknown field`);
    }
    const { latestVersion, latestBuild, minimumSupportedBuild, releaseNotes, storeUrl } = release;
    if (typeof latestVersion !== "string" || !versionPattern.test(latestVersion)) {
      problems.push(`${at("latestVersion")}: a version such as 2.3.0`);
    }
    if (!isWhole(latestBuild) || latestBuild < 1) problems.push(`${at("latestBuild")}: a whole number of 1 or more`);
    if (!isWhole(minimumSupportedBuild) || minimumSupportedBuild < 0) {
      problems.push(`${at("minimumSupportedBuild")}: a whole number of 0 or more`);
    } else if (isWhole(latestBuild) && minimumSupportedBuild > latestBuild) {
      // A minimum no build can meet would shut every user out.
      problems.push(`${at("minimumSupportedBuild")}: must not be above latestBuild`);
    }
    if (!isObject(releaseNotes) || typeof releaseNotes.en !== "string") {
      problems.push(`${at("releaseNotes")}: needs at least English (en)`);
    } else {
      for (const [language, note] of Object.entries(releaseNotes)) {
        if (!languagePattern.test(language)) problems.push(`${at("releaseNotes")}: "${language}" is not a language code`);
        if (typeof note !== "string" || note.trim() === "" || note.length > 2000) {
          problems.push(`${at(`releaseNotes.${language}`)}: text of 1 to 2000 characters`);
        }
      }
    }
    if (typeof storeUrl !== "string" || !isStorePage(storeUrl, platform)) {
      problems.push(`${at("storeUrl")}: an https address of ${storeHosts[platform].join(" or ")}`);
    }
  }
  return problems.length > 0 ? { problems } : { releases: value as unknown as Releases };
}

/** The answer of GET /api/app-updates; for the [asking] app it also says whether its build should or must update. */
export function appUpdatesAnswer(releases: Releases, asking?: { platform: Platform; build: number }) {
  const entry = (platform: Platform) => {
    const release = releases[platform];
    const build = asking?.platform === platform ? asking.build : undefined;
    return {
      latestVersion: release.latestVersion,
      latestBuild: release.latestBuild,
      minimumSupportedBuild: release.minimumSupportedBuild,
      // null: no installed build of this platform was given.
      updateAvailable: build === undefined ? null : build < release.latestBuild,
      updateRequired: build === undefined ? null : build < release.latestBuild && build < release.minimumSupportedBuild,
      releaseNotes: release.releaseNotes,
      storeUrl: release.storeUrl,
    };
  };
  return { schemaVersion: 1, android: entry("android"), ios: entry("ios") };
}

/** The platform and installed build named in the query, or an explanation of what is wrong with them. */
export function readQuery(params: URLSearchParams): { asking?: { platform: Platform; build: number } } | { error: string } {
  const platform = params.get("platform");
  const build = params.get("build");
  if (platform !== null && !platforms.includes(platform as Platform)) {
    return { error: `platform must be one of ${platforms.join(", ")}` };
  }
  if (build !== null && (platform === null || !/^\d{1,12}$/.test(build))) {
    return { error: "build must be a whole number, given with platform" };
  }
  return platform !== null && build !== null ? { asking: { platform: platform as Platform, build: Number(build) } } : {};
}

function isStorePage(value: string, platform: Platform): boolean {
  try {
    const url = new URL(value);
    return url.protocol === "https:" && !url.username && !url.password && !url.port && storeHosts[platform].includes(url.hostname);
  } catch {
    return false;
  }
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isWhole(value: unknown): value is number {
  return typeof value === "number" && Number.isSafeInteger(value);
}
