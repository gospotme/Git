<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Go Spot Me!</title>

    <link rel="stylesheet" type="text/css" href="StyleSheet.css">

    <!-- No Caching -->
    <meta http-equiv="cache-control" content="max-age=0" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="expires" content="0" />
    <meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT" />
    <meta http-equiv="pragma" content="no-cache" />

    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <meta charset="utf-8" />

    <!-- Marker Icons: http://mapicons.nicolasmollet.com/ -->

    <!-- <link rel="shortcut icon" type="image/x-icon" href="favicon.ico" /> -->
    <link rel="shortcut icon" type="image/x-icon" href="favicon.ico?v=2" />
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="logo_114.png" />
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="logo_72.png" />
    <link rel="apple-touch-icon-precomposed" href="logo_57.png" />
    <link rel="apple-touch-icon" href="logo_57.png" />

<!--    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="apple-touch-icon-114x114-precomposed.png" />
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="apple-touch-icon-72x72-precomposed.png" />
    <link rel="apple-touch-icon-precomposed" href="apple-touch-icon-57x57-precomposed.png" />
    <link rel="apple-touch-icon" href="apple-touch-icon.png" />
-->


    <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
    <!-- <script type="text/javascript" src="json.js"></script> -->
    
    <script type="text/javascript">
    <!--
        var btnGetCurrentLocation = null;
        var divCurrentLocation = null;
        var CurrentLocation = null;
        var btnSaveCurrentLocation = null;
        var tblSavedLocations = null;
        var SavedLocationForGPS = null;
        
        var SavedLocations = [];

        var body_OnLoad = function ()
        {
            btnGetCurrentLocation = document.getElementById("btnGetCurrentLocation");
            divCurrentLocation = document.getElementById("divCurrentLocation");
            btnSaveCurrentLocation = document.getElementById("btnSaveCurrentLocation");
            tblSavedLocations = document.getElementById("tblSavedLocations");

            SetCurrentLocationMapVisible(false);

            if (navigator.geolocation)
            {
                btnGetCurrentLocation.disabled = false;
                btnGetCurrentLocation.onclick = btnGetCurrentLocation_OnClick;
                btnSaveCurrentLocation.onclick = btnSaveCurrentLocation_OnClick;
            }
            else
            {
                btnGetCurrentLocation.disabled = true;
                btnGetCurrentLocation.value = "Go Spot Me! (Your device does not support GPS)"
                return;
            }

            if (typeof (Storage) === "undefined")
            {
                alert("Your browser doesn't support local storage.");
                btnGetCurrentLocation.disabled = false;
                return;
            }

            if (!JSON)
            {
                alert("Your browser doesn't have native JSON support.");
                btnGetCurrentLocation.disabled = false;
                return;
            }

            var SavedLocationsString = localStorage.getItem("SpotrSavedLocations");
            if (SavedLocationsString)
            {
                SavedLocations = JSON.parse(SavedLocationsString);
            }
            else
            {
                SavedLocations = [];
            }
            //alert(SavedLocations);

            PopulateSavedLocations();

            CheckForImport();
        };

        var CheckForImport = function ()
        {
            var SavedLocation = null;
            var Id = "";
            var Desc = "";
            var Lat = 0;
            var Lng = 0;
            var dt = new Date();

            Id = QueryString("id");
            if (Id == "")
            {
                return;
            }

            SavedLocation = GetSavedLocation(Id);
            if (SavedLocation != null)
            {
                return;
            }

            Desc = QueryString("desc");
            Lat = parseFloat(QueryString("lat"));
            Lng = parseFloat(QueryString("lng"));

            SavedLocation =
            {
                Id: Id,
                Desc: Desc,
                Pos: { Lat: Lat, Lng: Lng },
                UTC: dt.toISOString(),
                IsCurrent: false
            };

            if (SavedLocations == null)
            {
                SavedLocations = [];
            }

            SavedLocations.push(SavedLocation);
            SaveSavedLocations();

            // Update the UI with the new record
            PopulateSavedLocation(SavedLocation, true);

        };

        var QueryString = function (name)
        {
            name = name.toLowerCase().replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
            var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
             results = regex.exec(location.search);
            return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
        };

        var btnGetCurrentLocation_OnClick = function ()
        {
            if (!navigator.geolocation)
            {
                return;
            }

            if (GetCurrentLocationMapVisible() == true)
            {
                btnGetCurrentLocation.value = "Go Spot Me!";
                SetCurrentLocationMapVisible(false);
                btnGetCurrentLocation.disabled = false;
                return;
            }

            btnGetCurrentLocation.value = "Getting Your Location...";

            SetCurrentLocationMapVisible(false);
            //divCurrentLocation.innerHTML = "<b>Getting Location</b>";

            var GeoLocationOptions =
            {
                maximumAge: 60000,
                timeout: 30000,
                /* enableHighAccuracy: true */
                enableHighAccuracy: true
            };

            navigator.geolocation.getCurrentPosition(CurrentPosition_OnSuccess, CurrentPosition_OnError);
        };

        var SetCurrentLocationMapVisible = function (Visible)
        {
            if (Visible == true)
            {
                divCurrentLocation.style.visibility = "";
                divCurrentLocation.style.position = "";
                btnGetCurrentLocation.disabled = false;
                btnSaveCurrentLocation.style.visibility = "";
                btnSaveCurrentLocation.style.position = "";
            }
            else
            {
                divCurrentLocation.style.visibility = "hidden";
                divCurrentLocation.style.position = "absolute";
                btnGetCurrentLocation.disabled = true;
                btnSaveCurrentLocation.style.visibility = "hidden";
                btnSaveCurrentLocation.style.position = "absolute";
            }
        };

        var GetCurrentLocationMapVisible = function ()
        {
            return (divCurrentLocation.style.visibility != "hidden");
        };

        var CurrentPosition_OnError = function (Error)
        {
            var ErrorDescription = "An unknown error occurred.";

            switch (Error.code)
            {
                case Error.PERMISSION_DENIED:
                    ErrorDescription = "User denied the request for Geolocation."
                    break;
                case Error.POSITION_UNAVAILABLE:
                    ErrorDescription = "Location information is unavailable."
                    break;
                case Error.TIMEOUT:
                    ErrorDescription = "The request to get user location timed out."
                    break;
            }

            btnGetCurrentLocation.value = "Go Spot Me!";
            SetCurrentLocationMapVisible(false);
            //alert(ErrorDescription);
        };

        var CurrentPosition_OnSuccess = function (Position)
        {
            var dt = new Date();
            var Latitude = Position.coords.latitude;
            var Longitude = Position.coords.longitude;
            var Altitude = Position.coords.altitude;
            //var LatLng = new google.maps.LatLng(Latitude, Longitude);

            CurrentLocation =
            {
                Id: dt.getTime().toString(),
                /* UTC: dt.toUTCString(), */
                UTC: dt.toISOString(),
                Pos: { Lat: Latitude, Lng: Longitude },
                Desc: "You are here!",
                IsCurrent: true
            };

            // Must do this before showing the map
            btnGetCurrentLocation.value = "Don't Spot Me";
            SetCurrentLocationMapVisible(true);

            // Draw the map
            ShowGoogleMap(CurrentLocation, divCurrentLocation);

            // Update the current location on the saved locations
            RefreshCurrentLocationOnSavedLocations();
        };

        var ShowGoogleMap = function (Location, divMap, Location2)
        {
            var Latitude = Location.Pos.Lat;
            var Longitude = Location.Pos.Lng;
            var LatLng = new google.maps.LatLng(Latitude, Longitude);

            divMap.style.height = "250px";
            divMap.style.width = "100%";

            // See: https://developers.google.com/maps/documentation/javascript/reference
            var MapOptions =
            {
                center: LatLng,
                zoom: 20,
                /* mapTypeId: google.maps.MapTypeId.ROADMAP, */
                mapTypeId: google.maps.MapTypeId.HYBRID,
                mapTypeControl: true,
                navigationControlOptions: { style: google.maps.NavigationControlStyle.SMALL },
                draggable: false
            };
            var Map = new google.maps.Map(divMap, MapOptions);

            //google.maps.event.addListener(Map, "bounds_changed", function () { Map.setCenter(LatLng); });
            ////setTimeout(function () { divMap.style.width = "100px"; Map.setCenter(LatLng); }, 1000);

            var MarkerOptions =
            {
                map: Map,
                position: LatLng,
                /* title: "You are here!", */
                /* icon: { url: "favicon.png" } */
                icon: { url: "saved.png" }
            };
            if (Location.IsCurrent)
            {
                MarkerOptions.icon.url = "current.png";
            }
            var Marker = new google.maps.Marker(MarkerOptions);

            var InfoWindowOptions =
            {
                /* map: Map, */
                position: LatLng,
                /* pixelOffset: { width: 0, height: 100 }, */
                /* content: Location.Desc */
                content: "<a href='" + GetGoogleMapsURL(Location) + "' target='_blank'>" + Location.Desc + "</a>"
            };
            var InfoWindow = new google.maps.InfoWindow(InfoWindowOptions);
            //InfoWindow.open(Map, Marker);

            google.maps.event.addListener(Marker, "click", function () { InfoWindow.open(Map, Marker); });

            if (Location2)
            {
                var Latitude2 = Location2.Pos.Lat;
                var Longitude2 = Location2.Pos.Lng;
                var LatLng2 = new google.maps.LatLng(Latitude2, Longitude2);

                var MarkerOptions2 =
                {
                    map: Map,
                    position: LatLng2,
                    /* icon: { url: "favicon.png" } */
                    icon: { url: "saved.png" }
                };
                if (Location2.IsCurrent)
                {
                    MarkerOptions2.icon.url = "current.png";
                }

                var Marker2 = new google.maps.Marker(MarkerOptions2);

                var InfoWindowOptions2 =
                {
                    position: LatLng2,
                    content: "<a href='" + GetGoogleMapsURL(Location2) + "' target='_blank'>" + Location2.Desc + "</a>"
                };
                var InfoWindow2 = new google.maps.InfoWindow(InfoWindowOptions2);

                google.maps.event.addListener(Marker2, "click", function () { InfoWindow2.open(Map, Marker2); });

                var ne = new google.maps.LatLng((LatLng2.lat() > LatLng.lat() ? LatLng2.lat() : LatLng.lat()), (LatLng2.lng() < LatLng.lng() ? LatLng2.lng() : LatLng.lng()));
                var sw = new google.maps.LatLng((LatLng2.lat() < LatLng.lat() ? LatLng2.lat() : LatLng.lat()), (LatLng2.lng() > LatLng.lng() ? LatLng2.lng() : LatLng.lng()));

                var LatLngBounds = new google.maps.LatLngBounds(ne, sw);
                //Map.panToBounds(LatLngBounds);
                //Map.setZoom(10);
                Map.fitBounds(LatLngBounds);
                Map.setCenter(LatLngBounds.getCenter());
                //Map.setCenter(LatLng2);
                google.maps.event.addListener(Map, "bounds_changed", function () { Map.setCenter(LatLngBounds.getCenter()); });
            }
            else
            {
                google.maps.event.addListener(Map, "bounds_changed", function () { Map.setCenter(LatLng); });
            }

        };

        var btnSaveCurrentLocation_OnClick = function ()
        {
            var dt = new Date();
            var SavedLocation = null;

            //var SavedLocation = CurrentLocation;
            //            {
            //                Id: dt.getTime().toString(),
            //                UTC: dt.toUTCString(),
            //                Pos: CurrentLocation,
            //                Desc: "Test"
            //            };
            SavedLocation = JSON.parse(JSON.stringify(CurrentLocation));

            //var DefaultDescription = dt.toLocaleString();
            var DefaultDescription = "";
            var Description = prompt("Please enter a description (Ie: Parking Space #11)", DefaultDescription);
            if (Description == null || Description.trim() == "")
            {
                return;
            }

            SavedLocation.UTC = dt.toISOString();
            SavedLocation.Desc = Description;
            SavedLocation.IsCurrent = null;

            if (SavedLocations == null)
            {
                SavedLocations = [];
            }

            SavedLocations.push(SavedLocation);
            //SavedLocations.unshift(SavedLocation);

            SaveSavedLocations();

            // Update the UI with the new record
            SetCurrentLocationMapVisible(false);
            btnGetCurrentLocation.disabled = false;
            btnGetCurrentLocation.value = "Go Spot Me!"
            PopulateSavedLocation(SavedLocation, true);
        };

        var SaveSavedLocations = function ()
        {
            var SavedLocationsString = "";

            if (SavedLocations.length == 0)
            {
                localStorage.removeItem("SpotrSavedLocations");
                return;
            }

            SavedLocationsString = JSON.stringify(SavedLocations);
            //alert(SavedLocationsString);

            localStorage.setItem("SpotrSavedLocations", SavedLocationsString);
            //alert("Location Saved!");
        };

        var PopulateSavedLocations = function ()
        {
            var SavedLocation;
            var i;

            // Delete all of the rows from the table
            for (i = 0; i <= tblSavedLocations.rows.length - 1; i ++)
            {
                tblSavedLocations.deleteRow(i);
            }

            // Add all of the records to the table
            for (i = 0; i <= SavedLocations.length - 1; i ++)
            {
                SavedLocation = SavedLocations[i];
                PopulateSavedLocation(SavedLocation);
            }
        };

        var PopulateSavedLocation = function (SavedLocation, ShowMap)
        {
            var Row = null;
            var Col1 = null;
            var HTML = "";
            var divMap = null;
            var dt = new Date();

            //var DateTimeAdded = "";
            //DateTimeAdded = new Date(dt.toUTCString()).toLocaleString();

            // Build HTML for row
            HTML += "<table style='width: 100%'>\r\n"
            HTML += " <tr>\r\n"
            HTML += "  <td>\r\n"
            HTML += "   <hr />\r\n";
            HTML += "  </td>\r\n"
            HTML += " </tr>\r\n"
            HTML += " <tr>\r\n"
            HTML += "  <table><tr><td style='width: 1px'>\r\n"
            HTML += "   <img src='search.png' onclick='javascript: FindSavedLocation(\"" + SavedLocation.Id + "\");' /> \r\n";
            HTML += "  </td>\r\n"
            HTML += "  <td style='width: 100%'>\r\n"
            HTML += "   <span style='' id='lblDesc" + SavedLocation.Id + "' onclick='javascript: UpdateSavedLocation(\"" + SavedLocation.Id + "\");'>" + SavedLocation.Desc + "</div>\r\n";
            HTML += "  </td>\r\n"
            HTML += "  <td style='width: 1px'>\r\n"
            HTML += "   <img src='delete.png' onclick='javascript: DeleteSavedLocation(\"" + SavedLocation.Id + "\");' /> \r\n";
            HTML += "  </td></tr></table>\r\n"
            HTML += " </tr>\r\n"
            HTML += " <tr>\r\n"
            HTML += "  <table style='width: 100%'><tr><td style='width: 50%'>\r\n"
            HTML += "   <input type='button' style='width: 100%' id='btnShowCurrentLocationMap" + SavedLocation.Id + "' value='Show Saved Spot' onclick='javascript: ShowCurrentLocationMap(\"" + SavedLocation.Id + "\");' />\r\n";
            HTML += "  </td>\r\n"
            HTML += "  <td style='width: 50%'>\r\n"
            HTML += "   <input type='button' style='width: 100%' id='btnShowCurrentLocation" + SavedLocation.Id + "' value='Go Spot Me!' onclick='javascript: ShowCurrentLocation(\"" + SavedLocation.Id + "\");' />\r\n";
            HTML += "  </td></tr></table>\r\n"
            HTML += " </tr>\r\n"
            HTML += " <tr>\r\n"
            HTML += "  <table style='width: 100%'><tr><td style='width: 50%'>\r\n"
            HTML += "   <input type='button' style='width: 100%' id='btnGetDirections" + SavedLocation.Id + "' value='Directions' onclick='javascript: FindSavedLocation(\"" + SavedLocation.Id + "\");' />\r\n";
            HTML += "  </td>\r\n"
            HTML += "  <td style='width: 50%'>\r\n"
            HTML += "   <input type='button' style='width: 100%' id='btnEmailSavedLocation" + SavedLocation.Id + "' value='Email' onclick='javascript: EmailSavedLocation(\"" + SavedLocation.Id + "\");' />\r\n";
            HTML += "  </td></tr></table>\r\n"
            HTML += " <tr>\r\n"
            HTML += "  <td>\r\n"
            HTML += "   <div id='divMap" + SavedLocation.Id + "'></div>";
            HTML += "  </td>\r\n"
            HTML += " </tr>\r\n"
            HTML += "</table>\r\n"

            // Prepend the row into the table
            Row = tblSavedLocations.insertRow(0);
            Col1 = Row.insertCell(0);
            Col1.innerHTML = HTML;

            // Show the map for the record
            divMap = document.getElementById("divMap" + SavedLocation.Id);
            if (ShowMap == true)
            {
                ShowGoogleMap(SavedLocation, divMap);
            }
        };

        var GetSavedLocation = function (Id)
        {
            var SavedLocation = null;
            var i = 0;

            // Find the SavedLocation record
            for (i = 0; i <= SavedLocations.length - 1; i++)
            {
                SavedLocation = SavedLocations[i];
                if (SavedLocation.Id == Id)
                {
                    return SavedLocation;
                }
            }
        };

        var DeleteSavedLocation = function (Id)
        {
            var SavedLocation = null;
            var SavedLocationIndex = -1;
            var Row = null;
            var i = 0;

            // Find the SavedLocation record
            for (i = 0; i <= SavedLocations.length - 1; i++)
            {
                SavedLocation = SavedLocations[i];
                if (SavedLocation.Id == Id)
                {
                    SavedLocationIndex = i;
                    break;
                }
            }

            // Ensure that it exists
            if (SavedLocationIndex == -1)
            {
                return;
            }

            // Ask for confirmation to delete the record
            if (confirm("Are you sure you want to delete this saved location?") == false)
            {
                return;
            }

            // Remove the record from memory and save to disk
            SavedLocations.splice(SavedLocationIndex, 1);
            SaveSavedLocations();

            // Remove the record from the table
            for (i = 0; i <= tblSavedLocations.rows.length - 1; i++)
            {
                Row = tblSavedLocations.rows[i];
                if (Row.cells[0].innerHTML.indexOf(Id) != -1)
                {
                    tblSavedLocations.deleteRow(i);
                    break;
                }
            }

        };

        var UpdateSavedLocation = function (Id)
        {
            var SavedLocation = null;
            var lblDesc = null;
            var divMap = null;

            // Find the record
            SavedLocation = GetSavedLocation(Id);

            // Ensure that the record exists
            if (SavedLocation == null)
            {
                return;
            }

            // Prompt for new description
            var DefaultDescription = SavedLocation.Desc;
            var Description = prompt("Update description: ", DefaultDescription);
            if (Description == null || Description.trim() == "")
            {
                return;
            }

            // Update the record in memory
            SavedLocation.Desc = Description;
            // Save to disk
            SaveSavedLocations();

            // Update the label
            lblDesc = document.getElementById("lblDesc" + Id);
            lblDesc.innerHTML = SavedLocation.Desc;

            // Update the map
            divMap = document.getElementById("divMap" + Id);
            btnShowCurrentLocation.value = document.getElementById("btnShowCurrentLocation" + Id);
            
            ShowGoogleMap(SavedLocation, divMap, (btnShowCurrentLocation.value == "Don't Spot Me" ? CurrentLocation : null));
        };

        var FindSavedLocation = function (Id)
        {
            var SavedLocation = null;
            var URL = "";

            // Find the record
            SavedLocation = GetSavedLocation(Id);

            // Ensure that the record exists
            if (SavedLocation == null)
            {
                return;
            }

            // Build the URL
//            URL += "https://maps.google.com/?";
//            URL += "q=" + SavedLocation.Pos.Lat.toString() + "," + SavedLocation.Pos.Lng.toString();
            URL = GetGoogleMapsURL(SavedLocation);

            // Popup new window with directions
            window.open(URL, "_blank");

        };

        var GetGoogleMapsURL = function (Location)
        {
            var URL = "";
            URL += "https://maps.google.com/?";
            URL += "q=" + Location.Pos.Lat.toString() + "," + Location.Pos.Lng.toString();

            return URL;
        };

        var ShowCurrentLocation = function (Id)
        {
            var SavedLocation = null;
            var divMap = null;
            var btnShowCurrentLocation = null;
            var btnShowCurrentLocationMap = null;

            SavedLocation = GetSavedLocation(Id);

            if (SavedLocation == null)
            {
                return;
            }

            btnShowCurrentLocationMap = document.getElementById("btnShowCurrentLocationMap" + SavedLocation.Id);

            if (CurrentLocation == null)
            {
                if (!navigator.geolocation)
                {
                    return;
                }

                SavedLocationForGPS = SavedLocation;
                navigator.geolocation.getCurrentPosition(CurrentPosition_OnSuccess2, CurrentPosition_OnError);
                return;
            }

            // Draw the map
            divMap = document.getElementById("divMap" + SavedLocation.Id);
            btnShowCurrentLocation = document.getElementById("btnShowCurrentLocation" + SavedLocation.Id);

            if (btnShowCurrentLocation.value == "Go Spot Me!")
            {
                ShowGoogleMap(SavedLocation, divMap, CurrentLocation);
                btnShowCurrentLocation.value = "Don't Spot Me";
            }
            else
            {
                ShowGoogleMap(SavedLocation, divMap);
                btnShowCurrentLocation.value = "Go Spot Me!";
            }

            btnShowCurrentLocationMap.value = "Hide Saved Spot";
            divMap.style.visibility = "";
            divMap.style.position = "";
        };

        var ShowCurrentLocationMap = function (Id)
        {
            var SavedLocation = null;
            var divMap = null;
            var btnShowCurrentLocation = null;
            var btnShowCurrentLocationMap = null;

            SavedLocation = GetSavedLocation(Id);

            if (SavedLocation == null)
            {
                return;
            }

            // Draw the map
            divMap = document.getElementById("divMap" + SavedLocation.Id);
            btnShowCurrentLocation = document.getElementById("btnShowCurrentLocation" + SavedLocation.Id);
            btnShowCurrentLocationMap = document.getElementById("btnShowCurrentLocationMap" + SavedLocation.Id);

            if (btnShowCurrentLocationMap.value == "Show Saved Spot")
            {
                divMap.style.visibility = "";
                divMap.style.position = "";

                if (btnShowCurrentLocation.value == "Go Spot Me!")
                {
                    ShowGoogleMap(SavedLocation, divMap);
                }
                else
                {
                    ShowGoogleMap(SavedLocation, divMap, CurrentLocation);
                }

                btnShowCurrentLocationMap.value = "Hide Saved Spot";
            }
            else
            {
                divMap.style.visibility = "hidden";
                divMap.style.position = "absolute";
                btnShowCurrentLocationMap.value = "Show Saved Spot";
                btnShowCurrentLocation.value = "Go Spot Me!"
            }
        };

        var CurrentPosition_OnSuccess2 = function (Position)
        {
            var dt = new Date();
            var Latitude = Position.coords.latitude;
            var Longitude = Position.coords.longitude;
            var divMap = null;

            CurrentLocation =
            {
                Id: dt.getTime().toString(),
                UTC: dt.toISOString(),
                Pos: { Lat: Latitude, Lng: Longitude },
                Desc: "You are here!",
                IsCurrent: true
            };

            ShowCurrentLocation(SavedLocationForGPS.Id);
        };

        var RefreshCurrentLocationOnSavedLocations = function ()
        {
            var SavedLocation = null;
            var i = 0;
            var divMap = null;
            var btnShowCurrentLocation = null;

            // Find the SavedLocation record
            for (i = 0; i <= SavedLocations.length - 1; i++)
            {
                SavedLocation = SavedLocations[i];
                divMap = document.getElementById("divMap" + SavedLocation.Id);
                btnShowCurrentLocation = document.getElementById("btnShowCurrentLocation" + SavedLocation.Id);
                
                if (btnShowCurrentLocation.value == "Don't Spot Me")
                {
                    ShowGoogleMap(SavedLocation, divMap, CurrentLocation);
                }
            }
        };

        var EmailSavedLocation = function (Id)
        {
            var EmailUrl = "";
            var SavedLocationQueryString = "";
            var SpotrUrl = "";
            var SavedLocation = null;

            SavedLocation = GetSavedLocation(Id);

            if (SavedLocation == null)
            {
                return;
            }

            SavedLocationQueryString += "&id=" + SavedLocation.Id;
            SavedLocationQueryString += "&lat=" + SavedLocation.Pos.Lat;
            SavedLocationQueryString += "&lng=" + SavedLocation.Pos.Lng;
            SavedLocationQueryString += "&desc=" + escape(SavedLocation.Desc);

            SpotrUrl = "http://battaglia.homedns.org/spotr/Default.aspx?" + SavedLocationQueryString;

            EmailBody = "Hello!\n\nClick on the follow link to Go Spot Me!\n\n" + SpotrUrl;
            //EmailBody = "Hello!\n\nClick on the follow link to <a href=" + SpotrUrl + ">Go Spot Me!</a>\n\n";
            EmailBody = escape(EmailBody);

            EmailUrl = "mailto:?subject=Go Spot Me!&body=" + EmailBody;
            document.location = EmailUrl;

        };

    //-->
    </script>

</head>
<body onload="javascript: body_OnLoad();">
    <form id="form1" runat="server">
    <div>
        <image src="logo4.png"></image>
    </div>
    
    <table style="width: 100%">
        <tr>
            <td>
                <input type="button" id="btnGetCurrentLocation" value="Go Spot Me!" style="width: 100%" />
            </td>
        </tr>
        <tr>
            <td>
                <div id="divCurrentLocation"></div>
            </td>
        </tr>
        <tr>
            <td>
                <input type="button" id="btnSaveCurrentLocation" value="Save My Spot" style="width: 100%; font-weight: bold;" />
            </td>
        </tr>
    </table>

    <table id="tblSavedLocations" style="width: 100%"></table>

    <table style="width: 100%">
        <tr>
            <td>
                <div style="text-align: center;">
                    <a href="mailto:contact@gospotme.com?subject=Go Spot Me&body=">Contact</a>
                    |
                    Copyright © 2013
                </div>                
            </td>
        </tr>
    </table>

    </form>
</body>
</html>
