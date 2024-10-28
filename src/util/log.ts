import Logger from "bunyan";
import bunyanFormat from "bunyan-format";

export default function getLog( argv: { q?: boolean, v?: number, json?: boolean }) {
    return Logger.createLogger({
        name: "philippine-adm-maps",
        level: argv.q ? Number.POSITIVE_INFINITY : Math.max(30 - (argv.v * 10), 0),
        stream: bunyanFormat({
            outputMode: "short",
            levelInString: true
        }, argv.json ? process.stderr : process.stdout)
    });
}
