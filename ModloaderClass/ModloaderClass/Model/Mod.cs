//using CivLaucherDotNetCore.Controleur;
//using LibGit2Sharp;
//using LibGit2Sharp;
//using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Dynamic;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.CompilerServices;

namespace ModloaderClass.Model
{
    public class Mod
    {
        /*public ModController mController { get; set; }*/
        internal string repoUrl { get; set; }
        public string path { get; set; }
        public string apiUrl { get; set; }
        public string status { get; set; }
        private Repo repositoriInfo { get; set; }
        public string repoName
        {

            get { return repositoriInfo.depot; }

            set
            {
                if (repositoriInfo.depot != value)
                {
                    repositoriInfo.depot = value;
                }
            }
        }
        public string repoOwner
        {
            get { return repositoriInfo.owner; }
            set
            {
                if (repositoriInfo.owner != value)
                {
                    repositoriInfo.owner = value;
                }
            }
        }

        public bool IsInstalled()
        {
            return Directory.Exists(path);
        }
        public Mod(string civModFolder, string url, Repo repositoriInfo)
        {

            this.repositoriInfo = repositoriInfo;
            repoName = repositoriInfo.depot;
            path = civModFolder + "\\" + repositoriInfo.depot;
            apiUrl = url + "/" + repositoriInfo.owner + "/" + repositoriInfo.depot;
        }


    }

}

