using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace ModloaderClass.Model
{
    public class Config
    {
        public List<Repo>? listeMod { get; set; }
        public string? apiurl { get; set; }
        public string? civModFolder { get; set; }
        public string? shortCutName { get; set; }
        public string? repoUrl { get; set; }


        /*public Boolean CheckConfigAppData()
        {
            return (Directory.Exists(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "/ModLoader")
              &&
             File.Exists((Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "/ModLoader/appsettings.json")));
        }*/


        /*public void checkAndCPConfig()
        {

            if (!this.CheckConfigAppData())
            {

                if (!Directory.Exists(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "/ModLoader"))
                    Directory.CreateDirectory(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "/ModLoader");

                File.Copy( AppDomain.CurrentDomain.BaseDirectory + "\\Defaultappsettings.json", Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "/ModLoader/appsettings.json");
            }

        }*/


        /*public void SaveSettings()
        {
            string serializeConfig = JsonConvert.SerializeObject(this);
            File.WriteAllText(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "/ModLoader/appsettings.json", serializeConfig);
        }*/

    }
    public class Repo
    {
        public string owner { get; set; }
        public string depot { get; set; }
    }




}
