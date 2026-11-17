import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

import { appUpdatesAnswer, checkReleases, readQuery, type Releases } from "../src/app-updates.ts";

const published = JSON.parse(readFileSync(new URL("../src/releases.json", import.meta.url), "utf8"));

function releases(): Releases {
  return structuredClone(published);
}

test("the published releases are valid", () => {
  assert.deepEqual(checkReleases(published), { releases: published });
});

test("the answer says what each build should do, from the build numbers", () => {
  const all = releases();
  all.android.latestBuild = 30;
  all.android.minimumSupportedBuild = 25;
  const answer = (build: number) => appUpdatesAnswer(all, { platform: "android", build }).android;
  assert.deepEqual([answer(30).updateAvailable, answer(30).updateRequired], [false, false]);
  assert.deepEqual([answer(31).updateAvailable, answer(31).updateRequired], [false, false]);
  assert.deepEqual([answer(27).updateAvailable, answer(27).updateRequired], [true, false]);
  assert.deepEqual([answer(24).updateAvailable, answer(24).updateRequired], [true, true]);
});

test("each platform has its own release, and only the asking one is worked out", () => {
  const answer = appUpdatesAnswer(releases(), { platform: "ios", build: 1 });
  assert.equal(answer.ios.updateAvailable, true);
  assert.equal(answer.android.updateAvailable, null);
  assert.equal(answer.schemaVersion, 1);
  assert.equal(appUpdatesAnswer(releases()).ios.updateAvailable, null);
});

test("mistakes in the releases are caught before they reach the apps", () => {
  const cases: Array<(r: any) => void> = [
    (r) => { r.android.minimumSupportedBuild = r.android.latestBuild + 1; },
    (r) => { r.android.latestBuild = "28"; },
    (r) => { r.android.latestBuild = 27.5; },
    (r) => { r.ios.latestVersion = "two"; },
    (r) => { r.ios.storeUrl = "http://apps.apple.com/app/id6823419767"; },
    (r) => { r.ios.storeUrl = "https://example.com/WordsMap.ipa"; },
    (r) => { r.android.storeUrl = "https://apps.apple.com/app/id6823419767"; },
    (r) => { delete r.android.releaseNotes.en; },
    (r) => { r.android.releaseNotes["<b>"] = "x"; },
    (r) => { delete r.ios; },
    (r) => { r.windows = r.android; },
    (r) => { r.android.updateAvailable = true; },
  ];
  for (const breakIt of cases) {
    const broken = releases();
    breakIt(broken);
    assert.ok("problems" in checkReleases(broken), String(breakIt));
  }
});

test("the query is read strictly", () => {
  assert.deepEqual(readQuery(new URLSearchParams("platform=android&build=27")), { asking: { platform: "android", build: 27 } });
  assert.deepEqual(readQuery(new URLSearchParams("")), {});
  assert.deepEqual(readQuery(new URLSearchParams("platform=ios")), {});
  for (const bad of ["platform=windows", "platform=ios&build=abc", "build=5", "platform=ios&build=-1"]) {
    assert.ok("error" in readQuery(new URLSearchParams(bad)), bad);
  }
});
