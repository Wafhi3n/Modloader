//using ModloaderClass.Controleur;
//using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Configuration;

namespace ModloaderClass.Model
{
    public class BankMod
    {
        public string FullcivModFolder { get; set; }
        public Config config { get; set; }
        public List<Repo> repositoriesInfo { get; set; }
        public string apiurl { get; set; }
        public string civModFolder { get; set; }
        public List<Mod> mods { get; set; }

        public BankMod()
            {
       
              
                mods = new List<Mod>();


           
        }
        /*public BankMod(Config bindConfig)
        {
            try
            {
                config = bindConfig;
                apiurl = bindConfig.apiurl; ;
                repositoriesInfo = bindConfig.listeMod;
                civModFolder = bindConfig.civModFolder;
                FullcivModFolder = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + civModFolder;
                mods = new List<Mod>();


            }
            catch (ConfigurationErrorsException)
            {
                Console.WriteLine("Error reading app settings");
            }
        }*/
        /*public List<Mod> Mods
          {

              get { return this.modsValue; }

              set
              {
                  if (this.modsValue != value)
                  {
                      this.modsValue = value;
                      //NotifyPropertyChanged();
                  }
              }

          }*/

    }
}