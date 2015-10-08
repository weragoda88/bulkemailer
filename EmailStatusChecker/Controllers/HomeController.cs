using DataLayer;
using EmailStatusChecker.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace EmailStatusChecker.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {

            HomeModel model = new HomeModel();
            model.FillSettings();
            model.FillStatus();
            model.FillPenndingEmails();
            return View(model);
        }

        public ActionResult Details()
        {
            ViewBag.Message = "details page.";

            return View();
        }
    }
}