const fs = require('fs');
const path = require('path');

const VERSION_NAME = '1.0.4';
const VERSION_CODE = 4;

function readFileSafe(targetPath) {
  try {
    return fs.readFileSync(targetPath, { encoding: 'utf8' });
  } catch (error) {
    if (error.code === 'ENOENT') {
      console.log(`SKIP: ${targetPath} not found`);
      return null;
    }
    throw error;
  }
}

function writeFileSafe(targetPath, contents) {
  fs.writeFileSync(targetPath, contents, { encoding: 'utf8' });
  console.log(`UPDATED: ${targetPath}`);
}

function updatePubspecVersion(contents) {
  const regex = /^version:\s*([^\n\r#]+)/m;
  const match = contents.match(regex);
  if (!match) return { changed: false, contents };
  const current = match[1].trim();
  const [namePart] = current.split('+');
  const replacement = `version: ${VERSION_NAME}+${VERSION_CODE}`;
  if (current === `${namePart}+${VERSION_CODE}` && namePart === VERSION_NAME) {
    return { changed: false, contents };
  }
  const updated = contents.replace(regex, replacement);
  return { changed: true, contents: updated };
}

function updateAndroidBuildGradle(contents) {
  let changed = false;
  const versionNameRegex = /(versionName\s+)"[^"]+"/;
  const versionCodeRegex = /(versionCode\s+)\d+/;
  const updated = contents
    .replace(versionNameRegex, (_, prefix) => {
      changed = true;
      return `${prefix}"${VERSION_NAME}"`;
    })
    .replace(versionCodeRegex, (_, prefix) => {
      changed = true;
      return `${prefix}${VERSION_CODE}`;
    });
  return { changed, contents: updated };
}

function updateAndroidManifest(contents) {
  let changed = false;
  const nameRegex = /(android:versionName=")[^"]+(")/;
  const codeRegex = /(android:versionCode=")\d+(")/;
  const updated = contents
    .replace(nameRegex, (_, pre, post) => {
      changed = true;
      return `${pre}${VERSION_NAME}${post}`;
    })
    .replace(codeRegex, (_, pre, post) => {
      changed = true;
      return `${pre}${VERSION_CODE}${post}`;
    });
  return { changed, contents: updated };
}

function updateInfoPlist(contents) {
  let changed = false;
  const shortVersionRegex =
    /(<key>CFBundleShortVersionString<\/key>\s*<string>)[^<]+(<\/string>)/m;
  const bundleVersionRegex =
    /(<key>CFBundleVersion<\/key>\s*<string>)[^<]+(<\/string>)/m;
  const updated = contents
    .replace(shortVersionRegex, (_, pre, post) => {
      changed = true;
      return `${pre}${VERSION_NAME}${post}`;
    })
    .replace(bundleVersionRegex, (_, pre, post) => {
      changed = true;
      return `${pre}${VERSION_CODE}${post}`;
    });
  return { changed, contents: updated };
}

function processFile(targetPath, updater) {
  const contents = readFileSafe(targetPath);
  if (contents == null) return false;
  const { changed, contents: updated } = updater(contents);
  if (!changed) {
    console.log(`NO CHANGE: ${targetPath}`);
    return false;
  }
  writeFileSafe(targetPath, updated);
  return true;
}

function main() {
  const projectRoot = process.cwd();
  let updatedFiles = 0;

  const pubspecPath = path.join(projectRoot, 'pubspec.yaml');
  if (processFile(pubspecPath, updatePubspecVersion)) updatedFiles += 1;

  const gradlePath = path.join(projectRoot, 'android', 'app', 'build.gradle');
  if (processFile(gradlePath, updateAndroidBuildGradle)) updatedFiles += 1;

  const manifestPath = path.join(
    projectRoot,
    'android',
    'app',
    'src',
    'main',
    'AndroidManifest.xml'
  );
  if (processFile(manifestPath, updateAndroidManifest)) updatedFiles += 1;

  const plistPath = path.join(projectRoot, 'ios', 'Runner', 'Info.plist');
  if (processFile(plistPath, updateInfoPlist)) updatedFiles += 1;

  console.log(
    `Done. Updated ${updatedFiles} file(s) to versionName=${VERSION_NAME}, versionCode=${VERSION_CODE}.`
  );
}

main();
