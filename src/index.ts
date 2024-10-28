import getLog from "@/util/log";
import yargs from "yargs";
import {hideBin} from "yargs/helpers";

const argv = yargs( hideBin( process.argv ))
    .scriptName("philippine-maps")
    .option('v', {
        type: 'count',
        alias: 'verbose',
        description: 'Increase verbosity of output.'
    })
    .option('q', {
        type: 'boolean',
        alias: 'quiet',
        description: 'Suppress all output. Overrides --verbose.'
    })
    .option('json', {
        type: 'boolean',
        description: 'Output logs in JSON format.'
    })
    .commandDir( '.', {
        extensions: [ 'ts', 'js' ],
        exclude: /^index\.ts$/
    } )
    .help()
    .version()
    .demandCommand()
    .recommendCommands()
    .parse();

process.on("uncaughtException", async (err) => {
    getLog(await argv).fatal("Uncaught exception occurred:", err);
});
process.on("unhandledRejection", async (err) => {
    getLog(await argv).fatal("Unhandled rejection:", err);
});
