
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Collections.Generic;

namespace STT.Controllers
{
    public class cmd
    {
        public string command_name { get; set; }
        public List<string> command_args { get; set; }
    }

    [ApiController]
    [Route("api/[controller]")]
    public class MController: ControllerBase
    {
        [ApiExplorerSettings(IgnoreApi = true)]
        [HttpPost("upload")]
        public IActionResult UploadFile([FromForm] IFormFile file)
        {
            if(file== null)
            {
                return BadRequest("no file uploaded");
            }
            Console.WriteLine("file uploaded");
            var tempPath = Path.Combine(Path.GetTempPath(), file.FileName);
            using(var stream = new FileStream(tempPath, FileMode.Create))
            {
                file.CopyTo(stream);
            }

            string text = GetTranscript(tempPath);
            Console.WriteLine(text);
            System.IO.File.Delete(tempPath);
            var Rt_cmd = CreateCommand(text);

            Console.WriteLine("command name: " + Rt_cmd.command_name + " command args: ");
            foreach(var x in Rt_cmd.command_args)
            {
                Console.Write(x + " ");
            }
            return Ok(Rt_cmd);
        }

        private string GetTranscript(string filePath)
        {
            //string newpath = filePath.Replace("\\", "/");
            Console.WriteLine("sending the file");
            Process script = new Process();
            script.StartInfo.FileName = "python";
            script.StartInfo.ArgumentList.Clear();
            script.StartInfo.ArgumentList.Add("ToText.py");
            script.StartInfo.ArgumentList.Add(filePath);
            script.StartInfo.RedirectStandardOutput = true;
            script.StartInfo.UseShellExecute = false;
            script.StartInfo.StandardOutputEncoding = Encoding.UTF8;
            script.StartInfo.RedirectStandardError = true; 
            script.Start();

            string error = script.StandardError.ReadToEnd();
            if (!string.IsNullOrWhiteSpace(error))
            {
                Console.WriteLine("Error from Python:\n" + error);
            }

            return script.StandardOutput.ReadToEnd();

        }

        private cmd CreateCommand(string text)
        {
            HashSet<string> Commands = new HashSet<string>
            {
                "call",
                "open",
                "text",
            };
            string[] lst = text.Split(" ");
            cmd Current_cmd = new cmd();
            Current_cmd.command_name = lst[0];
            if (!Commands.Contains(Current_cmd.command_name)){
                Current_cmd.command_name = "plain";
                List<string> argsD = new List<string>();
                for (int i = 0; i < lst.Length; i++)
                {
                    argsD.Add(lst[i]);
                }
                Current_cmd.command_args = argsD;
                return Current_cmd;
            }
            List<string> args = new List<string>();
            for(int i = 1; i < lst.Length; i++)
            {
                args.Add(lst[i]);
            }
            Current_cmd.command_args = args;
            return Current_cmd;
        }

    }
}
