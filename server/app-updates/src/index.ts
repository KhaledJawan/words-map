// The Cloudflare Worker of wordsmap.nefrin.dev.
//
//   GET /api/app-updates[?platform=android|ios&build=<installed build>]
//       The newest WordsMap release of each platform (src/releases.json).
//   /, /privacy, /de, /de/privacy
//       The app's privacy policy on nefrin.dev, where the stores and the app link to.

import { appUpdatesAnswer, checkReleases, readQuery } from "./app-updates.ts";
import published from "./releases.json";

const checked = checkReleases(published);

const privacyPages: Record<string, string> = {
  "/": "https://nefrin.dev/wordsmap/privacy",
  "/privacy": "https://nefrin.dev/wordsmap/privacy",
  "/de": "https://nefrin.dev/de/wordsmap/privacy",
  "/de/privacy": "https://nefrin.dev/de/wordsmap/privacy",
};

export default {
  fetch(request: Request): Response {
    const url = new URL(request.url);
    if (request.method !== "GET" && request.method !== "HEAD") {
      return json({ error: "Only GET" }, 405, { Allow: "GET, HEAD" });
    }

    if (url.pathname === "/api/app-updates") {
      if ("problems" in checked) {
        // Never reaches the apps as a release: they keep what they knew.
        console.error("releases.json is not valid:", checked.problems);
        return json({ error: "The published releases are not valid" }, 503);
      }
      const query = readQuery(url.searchParams);
      if ("error" in query) return json({ error: query.error }, 400);
      return json(appUpdatesAnswer(checked.releases, query.asking), 200, {
        // Short enough that a new release reaches the apps within minutes.
        "Cache-Control": "public, max-age=300, s-maxage=300, stale-while-revalidate=3600",
      });
    }

    const page = privacyPages[url.pathname.replace(/\/+$/, "") || "/"];
    if (page) return Response.redirect(page, 302);
    return json({ error: "Not found" }, 404);
  },
};

function json(body: unknown, status: number, headers: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "X-Content-Type-Options": "nosniff",
      ...(status === 200 ? {} : { "Cache-Control": "no-store" }),
      ...headers,
    },
  });
}
