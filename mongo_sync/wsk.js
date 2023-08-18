// This script will export all wsks from mongo prod and update / add the relevant files in your currently checked out branch.  Run from the root of web-source-kinds or adjust the path on line 29. 


const fs = require('fs');
const util = require('util');
const exec = util.promisify(require('child_process').exec);


async function mongoExport() {
  try {
    const {stdout, stderr } = await exec(`mongoexport --uri="${process.env.MONGO_CONN_PROD}" -d "precog" -c "web-source-kinds" -o ./wsk.json`);
    console.log('stdout:', stdout);
    console.log('stderr:', stderr);
  } catch (e) {
    console.error(e);
  }
}

mongoExport().then(() => {
 fs.readFile('./wsk.json', "utf8", (err, data) => {
    if (err) {
      console.log(err);
      return;
    }
    let wsks =  JSON.parse("[" + data.replaceAll("}\n{", "},{") + "]");
    wsks.forEach(wsk => {
      delete wsk._id
      let name = wsk.id.replaceAll(" ", "_").replaceAll("@", "-").toLowerCase();
      fs.writeFile(`./modules/core/src/main/resources/web-source-kinds/${name}.json`, JSON.stringify(wsk, null, 2) + `\n`, (err) => {
        if (err)
          console.log(err);
        else {
          console.log(name)
        }
      });
    });
    console.log(wsks.length);
    exec(`rm ./wsk.json`);
  });
});
