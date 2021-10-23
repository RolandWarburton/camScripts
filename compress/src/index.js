#!/usr/bin/env node
import yargs from "yargs";
import readdirp from "readdirp";
import { execSync } from "node:child_process";
import path from "node:path";
import fs from "node:fs";

// Examples:
// index.js -c cam01 -t 15min -d hourly -b 4
// index.js -c cam01 -t 15min -d hourly -b 4 -w /mnt/borg/security-recordings
const argv = yargs(process.argv.slice(2))
  .usage("compress -c <camera> -t  <input> -d <output> -b <block size>")
  .demandOption(["c", "t", "d", "b"])
  .alias("c", "camera")
  .alias("t", "target")
  .alias("d", "destination")
  .alias("b", "blocks")
  .alias("w", "workspace")
  .default("w", process.cwd(), "working dir").argv;

async function main() {
  // get the working base where files are going to be sourced and placed
  let base = process.cwd();
  if (argv.w[0] == "/") {
    base = argv.w;
  } else {
    base = path.resolve(base, argv.w);
  }
  
  const readFilesPath = path.resolve(base, argv.t, argv.c);
  let files = [];
  for await (const entry of readdirp(readFilesPath, {
    fileFilter: "*.mp4",
    depth: 0,
    alwaysStat: true,
  })) {
    const ctime = new Date(entry.stats.ctime).getTime(); // the creation time of the file
    const now = Date.now() - 1000 * (argv.b * 100); // wait the number of videos * 100 seconds
  
    // ctime of the file is less than now + N seconds
    if (ctime < now) {
      files.push(entry.fullPath);
    } else {
      continue;
    }
  
    // we can now go through and concat the videos
    if (files.length >= argv.b) {
      // ensure we pick just the first 4 files
      console.log(`Compressing file batch:\n${files.join("\n- ")}`);
  
      // write the files to a tmp file
      fs.writeFileSync("/tmp/camScripts.queue", "file " + files.join("\nfile "));
  
      // use ffmpeg to concat them together
      execSync(
        `ffmpeg \
          -y \
          -hide_banner \
          -loglevel error \
          -safe 0 \
          -f concat \
          -i /tmp/camScripts.queue \
          -c copy \
          ${path.resolve(base, argv.d, argv.c, `${Date.now().toString()}.mp4`)}`
      );
  
      // clean up
      fs.unlinkSync("/tmp/camScripts.queue");
      for (const filePath of files) {
        fs.unlinkSync(filePath);
      }
      files = [];
    }
  }
}

main();

