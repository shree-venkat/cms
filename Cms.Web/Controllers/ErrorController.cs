﻿using System;
using System.Web.Mvc;

namespace Cms.Web.Controllers
{
    public class ErrorController : Controller
    {
        // GET: Error
        public ActionResult Index(HandleErrorInfo errorInfo)
        {
            Response.TrySkipIisCustomErrors = true;

            if (errorInfo == null)
            {
                errorInfo = new HandleErrorInfo(new Exception("An unrecognized error occurred."), "UNKNOWN", "UNKNOWN");
            }

            return View(errorInfo);
        }

        public ActionResult InvalidUrl(string url)
        {
            Response.TrySkipIisCustomErrors = true;

            Response.StatusCode = 404;

            var error = new HandleErrorInfo(new Exception("Invalid URL - " + url), "UNKNOWN", "UNKNOWN");

            return View("Index", error);
        }

        public ActionResult AccessDenied(string url)
        {
            Response.TrySkipIisCustomErrors = true;

            Response.StatusCode = 403;

            var error = new HandleErrorInfo(new Exception("Sorry, you're not authorized to perform this operation."), "UNKNOWN", "UNKNOWN");

            return View("Index", error);
        }

        public JsonResult AjaxResponse()
        {
            Response.TrySkipIisCustomErrors = true;

            Response.StatusCode = 500;

            var errorMessage = (string)Session["JSON_ERROR_MESSAGE"];
            Session["JSON_ERROR_MESSAGE"] = null;

            return new JsonResult() { Data = errorMessage, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
        }
    }
}