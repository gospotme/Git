var btnGetCurrentLocation=null,divCurrentLocation=null,CurrentLocation=null,btnSaveCurrentLocation=null,tblSavedLocations=null,SavedLocationForGPS=null,watchPositionId=null,WebSiteURL="http://www.gospotme.com",MaxAccuracyThreshold=1,MaxPositionCount=25,PositionCounter=0,FeetInMeter=3.28084,MapHeight="250px",Maps=[],Markers=[],Circles=[],InfoWindows=[],SavedLocations=[],IsiOS=/iPhone|iPad|iPod/i.test(navigator.userAgent),IsMobileDevice=/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent),
VerifyDomainUrl=function(){var a=GetDomainParts(),c=!1;"www"!=a.SubDomain?c=!0:"gospotme"!=a.Domain?c=!0:"com"!=a.Ext&&(c=!0);return!0==c?(document.location=WebSiteURL,!1):!0},body_OnLoad=function(){btnGetCurrentLocation=document.getElementById("btnGetCurrentLocation");divCurrentLocation=document.getElementById("divCurrentLocation");btnSaveCurrentLocation=document.getElementById("btnSaveCurrentLocation");tblSavedLocations=document.getElementById("tblSavedLocations");SetCurrentLocationMapVisible(!1);
btnGetCurrentLocation.style.visibility="";btnGetCurrentLocation.style.position="";if(navigator.geolocation)if(btnGetCurrentLocation.disabled=!1,btnGetCurrentLocation.onclick=btnGetCurrentLocation_OnClick,btnSaveCurrentLocation.onclick=btnSaveCurrentLocation_OnClick,"undefined"===typeof Storage)alertify.alert("Your browser doesn't support local storage."),btnGetCurrentLocation.disabled=!1;else if(JSON){var a=localStorage.getItem("SpotrSavedLocations");SavedLocations=a?JSON.parse(a):[];PopulateSavedLocations();
CheckForImport()}else alertify.alert("Your browser doesn't have native JSON support."),btnGetCurrentLocation.disabled=!1;else btnGetCurrentLocation.disabled=!0,btnGetCurrentLocation.value="Go Spot Me! (Your device does not support GPS)"},CheckForImport=function(){var a=null,c="",a="",d=0,b=0,e=new Date,g=-1,c=QueryString("id");""!=c&&(a=GetSavedLocation(c),null==a&&(a=QueryString("desc"),d=parseFloat(QueryString("lat")),b=parseFloat(QueryString("lng")),g=parseInt(QueryString("accuracy")),a={Id:c,
Desc:a,Pos:{Lat:d,Lng:b},UTC:e.toISOString(),IsCurrent:!1,Accuracy:g,BitLyUrl:""},a.BitLyUrl=GetLocationBitLyUrl(a),null==SavedLocations&&(SavedLocations=[]),SavedLocations.push(a),SaveSavedLocations(),PopulateSavedLocation(a,!0)))},QueryString=function(a){a=a.toLowerCase().replace(/[\[]/,"\\[").replace(/[\]]/,"\\]");a=RegExp("[\\?&]"+a+"=([^&#]*)").exec(location.search);return null==a?"":decodeURIComponent(a[1].replace(/\+/g," "))},GetDomainParts=function(){var a=window.location.host.split(".");
return{SubDomain:a[0],Domain:a[1],Ext:a[2],Type:a[3]}},GeoLocationOptions={maximumAge:0,timeout:3E4,allowHighAccuracy:!0,enableHighAccuracy:!0},btnGetCurrentLocation_OnClick=function(){navigator.geolocation&&(!0==GetCurrentLocationMapVisible()?(watchPositionId&&(navigator.geolocation.clearWatch(watchPositionId),watchPositionId=null),btnGetCurrentLocation.value="Go Spot Me!",SetCurrentLocationMapVisible(!1),btnGetCurrentLocation.disabled=!1):(btnGetCurrentLocation.value="Getting Your Location...",
btnGetCurrentLocation.disabled=!0,SetCurrentLocationMapVisible(!1),watchPositionId&&(navigator.geolocation.clearWatch(watchPositionId),watchPositionId=null),watchPositionId=navigator.geolocation.watchPosition(function(a){CurrentPosition_OnSuccess3(a,!1)},CurrentPosition_OnError,GeoLocationOptions)))},SetCurrentLocationMapVisible=function(a){!0==a&&"0px"==divCurrentLocation.style.height?(btnSaveCurrentLocation.style.visibility="",btnSaveCurrentLocation.style.position=""):!1==a&&"0px"!=divCurrentLocation.style.height&&
(HideGoogleMap(CurrentLocation,divCurrentLocation),btnGetCurrentLocation.disabled=!0,btnSaveCurrentLocation.style.visibility="hidden",btnSaveCurrentLocation.style.position="absolute")},GetCurrentLocationMapVisible=function(){return"0px"!=divCurrentLocation.style.height},CurrentPosition_OnError=function(a){var c="An unknown error occurred.";switch(a.code){case a.PERMISSION_DENIED:c="User denied the request for Geolocation.";break;case a.POSITION_UNAVAILABLE:c="Location information is unavailable.";
break;case a.TIMEOUT:c="The request to get user location timed out."}SetCurrentLocationMapVisible(!1);btnGetCurrentLocation.value="Go Spot Me!";btnGetCurrentLocation.disabled=!1;alertify.alert(c)},CurrentPosition_OnSuccess=function(a){var c=new Date,d=a.coords.latitude,b=a.coords.longitude;a=a.coords.accuracy;CurrentLocation={Id:c.getTime().toString(),UTC:c.toISOString(),Pos:{Lat:d,Lng:b},Desc:"You are here!",IsCurrent:!0,Accuracy:a,BitLyUrl:""};"Go Spot Me"!=btnGetCurrentLocation.value&&(btnGetCurrentLocation.value=
"Don't Spot Me",SetCurrentLocationMapVisible(!0),ShowGoogleMap(CurrentLocation,divCurrentLocation));RefreshCurrentLocationOnSavedLocations()},HideGoogleMap=function(a,c,d){d="-1";var b=null,e=null,g=null;a&&!a.IsCurrent&&(d=a.Id);b=Markers[d];e=Circles[d];g=InfoWindows[d];b&&b.setVisible(!1);g&&g.close();e&&e.setVisible(!1);a=d+":2";e=b=d=null;d=Markers[a];b=Circles[a];e=InfoWindows[a];d&&d.setVisible(!1);e&&e.close();b&&b.setVisible(!1);c.style.height="0px"},ShowGoogleMap=function(a,c,d){var b=a.Accuracy,
e=new google.maps.LatLng(a.Pos.Lat,a.Pos.Lng),g="-1",k=null,m=null,f=null;c.cssClass="ShowCurrentLocation";f="0px"==c.style.height;c.style.height=MapHeight;c.style.width="100%";if(!0==f)setTimeout(function(){ShowGoogleMap(a,c,d)},500),setTimeout(function(){window_OnResize()},500);else{a.IsCurrent||(g=a.Id);k=Maps[g];m=Markers[g];f=Circles[g];InfoWindow=InfoWindows[g];k||(k=new google.maps.Map(c,{center:e,zoom:20,mapTypeId:google.maps.MapTypeId.HYBRID,mapTypeControl:!0,navigationControlOptions:{style:google.maps.NavigationControlStyle.SMALL},
draggable:!1}),Maps[g]=k);if(!m){var h={map:k,position:e,zIndex:0,icon:{url:"saved.png"}};a.IsCurrent&&(h.icon.url="current.png");m=new google.maps.Marker(h);m.setAnimation(google.maps.Animation.DROP);Markers[g]=m}!1==m.getVisible()&&(m.setAnimation(google.maps.Animation.DROP),m.setVisible(!0));InfoWindow||(h={position:e,content:"<a href='"+GetGoogleMapsURL(a)+"' target='_blank'>"+a.Desc+"</a>"},InfoWindow=new google.maps.InfoWindow(h),InfoWindows[g]=InfoWindow,google.maps.event.addListener(m,"click",
function(){InfoWindow.open(k,m)}));InfoWindow.setContent("<a href='"+GetGoogleMapsURL(a)+"' target='_blank'>"+a.Desc+"</a>");f||(f={map:k,posicentertion:e,fillColor:"#A0FFA0",fillOpacity:0.5,radius:b,strokeWeight:1,strokeColor:"#408040",strokeOpacity:1},a.IsCurrent&&(f.fillColor="#A0A0FF",f.strokeColor="#404080"),f=new google.maps.Circle(f),Circles[g]=f);!1==f.getVisible()&&f.setVisible(!0);f.radius=b;f.setCenter(e);m.setPosition(e);k.setCenter(e);if(d){var g=d.Accuracy,b=new google.maps.LatLng(d.Pos.Lat,
d.Pos.Lng),f=a.Id+":2",l=Markers[f],h=Circles[f],n=InfoWindows[f];if(!l){var p={map:k,position:b,zIndex:1,icon:{url:"saved.png"}};d.IsCurrent&&(p.icon.url="current.png");l=new google.maps.Marker(p);l.setAnimation(google.maps.Animation.DROP);Markers[f]=l}!1==l.getVisible()&&(l.setAnimation(google.maps.Animation.DROP),l.setVisible(!0));n||(p={position:b,content:"<a href='"+GetGoogleMapsURL(d)+"' target='_blank'>"+d.Desc+"</a>"},n=new google.maps.InfoWindow(p),InfoWindows[f]=n,google.maps.event.addListener(l,
"click",function(){n.open(k,l)}));n.setContent("<a href='"+GetGoogleMapsURL(d)+"' target='_blank'>"+d.Desc+"</a>");h||(h={map:k,posicentertion:b,fillColor:"#A0FFA0",fillOpacity:0.5,radius:g,strokeWeight:1,strokeColor:"#408040",strokeOpacity:1},d.IsCurrent&&(h.fillColor="#A0A0FF",h.strokeColor="#404080"),h=new google.maps.Circle(h),Circles[f]=h);!1==h.getVisible()&&h.setVisible(!0);h.radius=g;h.setCenter(b);l.setPosition(b);g=new google.maps.LatLng(b.lat()>e.lat()?b.lat():e.lat(),b.lng()<e.lng()?b.lng():
e.lng());e=new google.maps.LatLng(b.lat()<e.lat()?b.lat():e.lat(),b.lng()>e.lng()?b.lng():e.lng());e=new google.maps.LatLngBounds(g,e);k.fitBounds(e);k.setCenter(e.getCenter())}else f=a.Id+":2",l=Markers[f],h=Circles[f],n=InfoWindows[f],l&&l.setVisible(!1),n&&n.close(),h&&h.setVisible(!1)}},btnSaveCurrentLocation_OnClick=function(){watchPositionId&&(navigator.geolocation.clearWatch(watchPositionId),watchPositionId=null);alertify.prompt2("Please enter a description (Ie: Parking Space #11)",function(a,
c){a?null!=c&&""!=c.trim()&&btnSaveCurrentLocation_OnClick2(c):(SetCurrentLocationMapVisible(!1),btnGetCurrentLocation_OnClick())},"")};alertify.prompt2=function(a,c,d){var b=null,b=alertify.prompt(a,c,d);SetFocusToAterifyPrompt();return b};
var SetFocusToAterifyPrompt=function(){var a=document.getElementById("alertify-text");null!=a&&(a.select(),a.focus())},btnSaveCurrentLocation_OnClick2=function(a){var c=new Date,d=null,d=JSON.parse(JSON.stringify(CurrentLocation));d.UTC=c.toISOString();d.Desc=a;d.IsCurrent=null;d.BitLyUrl=GetLocationBitLyUrl(d);null==SavedLocations&&(SavedLocations=[]);SavedLocations.push(d);SaveSavedLocations();watchPositionId&&(navigator.geolocation.clearWatch(watchPositionId),watchPositionId=null);SetCurrentLocationMapVisible(!1);
btnGetCurrentLocation.disabled=!1;btnGetCurrentLocation.value="Go Spot Me!";PopulateSavedLocation(d,!1);ShowSavedLocation(d.Id)},SaveSavedLocations=function(){var a="";0==SavedLocations.length?localStorage.removeItem("SpotrSavedLocations"):(a=JSON.stringify(SavedLocations),localStorage.setItem("SpotrSavedLocations",a))},PopulateSavedLocations=function(){var a,c;for(c=0;c<=tblSavedLocations.rows.length-1;c++)tblSavedLocations.deleteRow(c);for(c=0;c<=SavedLocations.length-1;c++)a=SavedLocations[c],
PopulateSavedLocation(a)},PopulateSavedLocation=function(a,c){var d=null,d=null,b;b=null;b="   <hr />\r\n"+("<table id='tblParentSavedLocation"+a.Id+"' style='width: 100%'>");b+=" <tr><td style='width: 1px'>\r\n";b+="   <a id='aShowSavedLocation"+a.Id+"' href='#' onclick='javascript: ShowSavedLocation(\""+a.Id+"\"); return false;'><img src='search.png' /></a>\r\n";b+="  </td>\r\n";b+="  <td style='width: 100%'>\r\n";b+="   <a href='#'onclick='javascript: UpdateSavedLocation(\""+a.Id+"\"); return false;' style='text-decoration: none; color: black;'><span id='lblDesc"+
a.Id+"'>"+a.Desc+"</span></a>\r\n";b+="  </td>\r\n";b+="  <td style='width: 1px'>\r\n";b+="   <a href='#' onclick='javascript: DeleteSavedLocation(\""+a.Id+"\"); return false;'><img src='delete.png' /></a>\r\n";b+="  </td></tr></table>\r\n";b+=" </tr>\r\n";b+="</table>\r\n";b+="<table id='tblSavedLocation"+a.Id+"' style='width: 100%; visibility: hidden; position: absolute; height: 0px;' class='SavedLocationTable'>";b+=" <tr><td>\r\n";b+="<table style='width: 100%'>";b+=" <tr><td>\r\n";b+="  <table style='width: 100%'><tr><td style='width: 50%'>\r\n";
b+="   <input type='button' style='width: 100%' id='btnShowCurrentLocation"+a.Id+"' value='Go Spot Me!' onclick='javascript: ShowCurrentLocation(\""+a.Id+"\");' />\r\n";b+="  </td>\r\n";b+="  <td style='width: 50%'>\r\n";b+="   <input type='button' style='width: 100%' id='btnGetDirections"+a.Id+"' value='Get Directions' onclick='javascript: FindSavedLocation(\""+a.Id+"\");' />\r\n";b+="  </td></tr></table>\r\n";b+=" </td></tr>\r\n";b+=" <tr><td>\r\n";!0==IsiOS?(b+="  <table style='width: 100%'><tr><td style='width: 50%'>\r\n",
b+="   <input type='button' style='width: 100%' id='btnShareSavedLocation"+a.Id+"' value='Share' onclick='javascript: ShareSavedLocation(\""+a.Id+"\");' />\r\n",b+="  </td>\r\n",b+="  <td style='width: 50%'>\r\n"):!1==IsMobileDevice?(b+="  <table style='width: 100%'><tr><td style='width: 50%'>\r\n",b+="   <input type='button' style='width: 100%' id='btnShareSavedLocation"+a.Id+"' value='Share' onclick='javascript: ShareSavedLocation(\""+a.Id+"\");' />\r\n",b+="  </td>\r\n",b+="  <td style='width: 50%'>\r\n"):
(b+="  <table style='width: 100%'><tr><td style='width: 33%'>\r\n",b+="   <input type='button' style='width: 100%' id='btnShareSavedLocation"+a.Id+"' value='Share' onclick='javascript: ShareSavedLocation(\""+a.Id+"\");' />\r\n",b+="  </td>\r\n",b+="  <td style='width: 33%'>\r\n",b+="   <input type='button' style='width: 100%' id='btnTextSavedLocation"+a.Id+"' value='Text' onclick='javascript: TextSavedLocation(\""+a.Id+"\");' />\r\n",b+="  </td>\r\n",b+="  <td style='width: 33%'>\r\n");b+="   <input type='button' style='width: 100%' id='btnEmailSavedLocation"+
a.Id+"' value='Email' onclick='javascript: EmailSavedLocation(\""+a.Id+"\");' />\r\n";b+="  </td></tr></table>\r\n";b+=" </td></tr>\r\n";b+="</table>\r\n";b+="<table style='width: 100%'>\r\n";b+=" <tr>\r\n";b+="  <td>\r\n";b+="   <div id='divMap"+a.Id+"' style='height: 0px;' class='ShowCurrentLocation'></div>";b+="  </td>\r\n";b+=" </tr>\r\n";b+="</table>\r\n";b+=" </td></tr>\r\n";b+="</table>\r\n";d=tblSavedLocations.insertRow(0);d=d.insertCell(0);d.innerHTML=b;b=document.getElementById("divMap"+
a.Id);!0==c&&ShowGoogleMap(a,b)},GetSavedLocation=function(a){for(var c=null,d=0,d=0;d<=SavedLocations.length-1;d++)if(c=SavedLocations[d],c.Id==a)return c},DeleteSavedLocation=function(a){alertify.confirm("Are you sure you want to delete this saved location?",function(c){c&&DeleteSavedLocation2(a)})},DeleteSavedLocation2=function(a){for(var c=null,d=-1,c=null,b=0,b=0;b<=SavedLocations.length-1;b++)if(c=SavedLocations[b],c.Id==a){d=b;break}if(-1!=d)for(SavedLocations.splice(d,1),SaveSavedLocations(),
b=0;b<=tblSavedLocations.rows.length-1;b++)if(c=tblSavedLocations.rows[b],-1!=c.cells[0].innerHTML.indexOf(a)){tblSavedLocations.deleteRow(b);break}},ShowSavedLocation=function(a){var c=null,d=null,c=GetSavedLocation(a);null!=c&&(d=document.getElementById("tblSavedLocation"+c.Id),document.getElementById("tblParentSavedLocation"+c.Id),aShowSavedLocation=document.getElementById("aShowSavedLocation"+c.Id),"hidden"==d.style.visibility?(d.style.visibility="",d.style.position="",d.style.height=MapHeight):
d.style.height==MapHeight&&(d.style.height="0px",setTimeout(function(){d.style.visibility="hidden";d.style.position="absolute"},150)),ShowCurrentLocationMap(c.Id),aShowSavedLocation.onclick=function(){return!1},setTimeout(function(){aShowSavedLocation.onclick=function(){ShowSavedLocation(a);return!1}},500))},UpdateSavedLocation=function(a){var c=null,c=GetSavedLocation(a);null!=c&&alertify.prompt2("Update description: ",function(a,b){a&&null!=b&&""!=b.trim()&&UpdateSavedLocation2(c,b)},c.Desc)},UpdateSavedLocation2=
function(a,c){var d=a.Id,b=null,b=null;a.Desc=c;SaveSavedLocations();b=document.getElementById("lblDesc"+d);b.innerHTML=a.Desc;b=document.getElementById("divMap"+d);btnShowCurrentLocation=document.getElementById("btnShowCurrentLocation"+d);document.getElementById("tblSavedLocation"+d);b.style.height==MapHeight&&ShowGoogleMap(a,b,"Don't Spot Me"==btnShowCurrentLocation.value?CurrentLocation:null)},FindSavedLocation=function(a){var c=null,c="",c=GetSavedLocation(a);null!=c&&(c=GetGoogleMapsURL(c),window.open(c,
"_blank"))},GetGoogleMapsURL=function(a){return a="https://maps.google.com/?"+("q="+a.Pos.Lat.toString()+","+a.Pos.Lng.toString())},ShowCurrentLocation=function(a){var c=null,d=null,b=null,c=GetSavedLocation(a);null!=c&&(d=document.getElementById("divMap"+c.Id),b=document.getElementById("btnShowCurrentLocation"+c.Id),null==watchPositionId&&"Go Spot Me!"==b.value?(b.value="Don't Spot Me",btnGetCurrentLocation_OnClick(),setTimeout(function(){d.scrollIntoView()},500)):"Go Spot Me!"==b.value?(ShowGoogleMap(c,
d,CurrentLocation),b.value="Don't Spot Me"):(ShowGoogleMap(c,d),b.value="Go Spot Me!"))},ShowCurrentLocationMap=function(a){var c=null,d=null,b=null,c=GetSavedLocation(a);null!=c&&(d=document.getElementById("divMap"+c.Id),b=document.getElementById("btnShowCurrentLocation"+c.Id),document.getElementById("tblSavedLocation"+a),"0px"==d.style.height?"Go Spot Me!"==b.value?ShowGoogleMap(c,d):ShowGoogleMap(c,d,CurrentLocation):d.style.height==MapHeight&&(HideGoogleMap(c,d,CurrentLocation),b.value="Go Spot Me!"))},
CurrentPosition_OnSuccess2=function(a){var c=new Date,d=a.coords.latitude,b=a.coords.longitude;a=a.coords.accuracy;CurrentLocation={Id:c.getTime().toString(),UTC:c.toISOString(),Pos:{Lat:d,Lng:b},Desc:"You are here!",IsCurrent:!0,Accuracy:a,BitLyUrl:""};ShowCurrentLocation(SavedLocationForGPS.Id)},CurrentPosition_OnSuccess3=function(a,c){var d=new Date,b=a.coords.latitude,e=a.coords.longitude,g=a.coords.accuracy;CurrentLocation={Id:d.getTime().toString(),UTC:d.toISOString(),Pos:{Lat:b,Lng:e},Desc:"You are here!",
IsCurrent:!0,Accuracy:g,BitLyUrl:""};c?ShowCurrentLocation(SavedLocationForGPS.Id):("Go Spot Me"!=btnGetCurrentLocation.value&&(SetCurrentLocationMapVisible(!0),setTimeout(function(){btnGetCurrentLocation.value="Don't Spot Me";btnGetCurrentLocation.disabled=!1},500),ShowGoogleMap(CurrentLocation,divCurrentLocation)),RefreshCurrentLocationOnSavedLocations())},RefreshCurrentLocationOnSavedLocations=function(){for(var a=null,c=0,d=null,b=null,c=0;c<=SavedLocations.length-1;c++)a=SavedLocations[c],d=
document.getElementById("divMap"+a.Id),b=document.getElementById("btnShowCurrentLocation"+a.Id),"Don't Spot Me"==b.value&&ShowGoogleMap(a,d,CurrentLocation)},ShareSavedLocation=function(a){SavedLocation=GetSavedLocation(a);null!=SavedLocation&&!1!=VerifyLocationBitLyUrl(SavedLocation)&&(SpotrUrl=SavedLocation.BitLyUrl,!0==IsMobileDevice?(alertify.prompt2("Please copy the following URL to share this saved spot:",function(){},SavedLocation.BitLyUrl),document.getElementById("alertify-cancel").style.visibility=
"hidden"):alertify.alert("Please copy the following URL to share this saved spot:\n\n"+SavedLocation.BitLyUrl))},EmailSavedLocation=function(a){var c="",d="",d=null,c="",d=GetSavedLocation(a);null!=d&&!1!=VerifyLocationBitLyUrl(d)&&(d=d.BitLyUrl,c=c+("Hello!\n\nClick on the follow link to Go Spot Me!\n\n"+d)+"\n(If you are unable to click the link then copy and paste it into a browser's address bar)",c=escape(c),c="mailto:?subject=Go Spot Me!&body="+c,document.location=c)},TextSavedLocation=function(a){var c=
"",d="",d=null,c="",d=GetSavedLocation(a);null!=d&&!1!=VerifyLocationBitLyUrl(d)&&(d=d.BitLyUrl,c=c+("Hello!\n\nClick on the follow link to Go Spot Me!\n\n"+d)+"\n(If you are unable to click the link then copy and paste it into a browser's address bar)",c=escape(c),c=!0==IsiOS?"sms:;body="+c:"sms:?body="+c,document.location=c)},GenerateBitLyUrl=function(a){a="https://api-ssl.bitly.com/v3/shorten?access_token=f9c1b018d84c0cad078921e196ad79b158e0184a&longUrl="+escape(a);xmlhttp=window.XMLHttpRequest?
new XMLHttpRequest:new ActiveXObject("Microsoft.XMLHTTP");xmlhttp.open("GET",a,!1);xmlhttp.send();return 4==xmlhttp.readyState&&200==xmlhttp.status?(resp=JSON.parse(xmlhttp.responseText),resp.data.url):""},GetLocationBitLyUrl=function(a){var c,d="";c="&id="+a.Id;c+="&lat="+a.Pos.Lat;c+="&lng="+a.Pos.Lng;c+="&desc="+escape(a.Desc);c+="&accuracy="+a.Accuracy;d+=WebSiteURL+"?";d+=c+"&m=";return GenerateBitLyUrl(d)},VerifyLocationBitLyUrl=function(a){a.BitLyUrl&&""!=a.BitLyUrl||(a.BitLyUrl=GetLocationBitLyUrl(a));
if(""==a.BitLyUrl)return alertify.alert("Failed generating Bitly URL"),!1;SaveSavedLocations();return!0},window_OnResize=function(){var a=null,c=null,d;for(d in Maps)if(a=Maps[d])c=a.getCenter(),google.maps.event.trigger(a,"resize"),a.setCenter(c)};window.onresize=window_OnResize;