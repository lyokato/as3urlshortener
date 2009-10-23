package org.coderepos.webservices
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.ErrorEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;

    import com.adobe.net.URI;
    import com.adobe.serialization.json.JSON;

    import org.coderepos.webservices.events.URLShortenerEvent;
    import org.coderepos.webservices.events.URLShortenerEventResult;

    /*
     * import org.coderepos.webservices.Bitly;
     * import org.coderepos.webservices.IURLShortener;
     * import org.coderepos.webservices.events.URIShortenerEvent;
     * import com.adobe.net.URI;
     *
     * import flash.events.IOErrorEvent;
     * import flash.events.SecurityErrorEvent;
     *
     * var bitly:IURLShortener = new BitlyClient(userID, apiKey);
     * bitly.addEventListener(URIShortenerEvent.SHORTENED,
     *     shortenCompleteHandler);
     * bitly.addEventListener(URIShortenerEvent.EXPANDED,
     *     expandedCompleteHandler);
     * bitly.addEventListener(URIShortenerEvent.ERROR, errorHandler);
     * bitly.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
     * bitly.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
     *
     * if (!bitly.isFetching && bitly.matchURI(originalURL)) {
     *     bitly.shorten(originalURL);
     * }
     *
     * private function shortenCompleteHandler(e:URIShortenerEvent):void
     * {
     *     vr shortenedURL:URI = e.result.url;
     * }
     *
     * private function errorHandler(e:URLShortenerEvent):void
     * {
     *    trace(e.result.code);
     *    trace(e.result.message);
     * }
     *
     *
     * if (!bitly.isFetching && bitly.matchURI(shortenedURL)) {
     *   bitly.expand(shortendedURL);
     * }
     *
     *
     * private function expandedCompleteHandler(e:URLShortenerEvent):void {
     *    var originalURL:URI = e.result.url;
     * }
     *
     */

    public class BitlyClient extends EventDispatcher implements IURLShortener
    {
        public static const BITLY:String = "bitly";
        public static const JMP:String = "jmp";

        private var _userID:String;
        private var _apiKey:String;
        private var _type:String // (BITLY|JMP)
        private var _loader:URLLoader;
        private var _isFetching:Boolean;

        public function BitlyClient(userID:String, apiKey:String,
            type:String=BitlyClient.JMP)
        {
            _userID = userID;
            _apiKey = apiKey;
            _type = type;
            _isFetching = false;
        }

        public function get isFetching():Boolean
        {
            return _isFetching;
        }

        public function shorten(url:URI):void
        {
            if (_isFetching)
                throw new Error("fetching.");
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, shortenCompleteHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            var endpoint:String = (_type == JMP)
                ? "http://api.j.mp/shorten" : "http://api.bit.ly/shorten";
            var reqURI:URI = new URI(endpoint);
            var queryMap:Object = new Object();
            queryMap.version = "2.0.1";
            queryMap.longUrl = url.toString();
            queryMap.apiKey = _apiKey;
            queryMap.login = _userID;
            queryMap.format = "json";
            reqURI.setQueryByMap(queryMap);
            _isFetching = true;
            _loader.load(new URLRequest(reqURI.toString()));
        }

        private function shortenCompleteHandler(e:Event):void
        {
            _isFetching = false;
            var res:String = _loader.data as String;
            var obj:Object = JSON.decode(res);
            var result:URLShortenerEventResult = new URLShortenerEventResult();
            if (obj != null && "statusCode" in obj && obj.statusCode == "OK") {
                if ("results" in obj) {
                    for each(var pair:Object in obj.results) {
                        if ("shortUrl" in pair) {
                            result.url = new URI(pair.shortUrl);
                        }
                        break;
                    }
                    if (result.url != null) {
                        dispatchEvent(new URLShortenerEvent(URLShortenerEvent.SHORTENED, result));
                    } else {
                        result.code = 999;
                        result.message = "unknown response format." + res;
                        dispatchEvent(new URLShortenerEvent(URLShortenerEvent.ERROR, result));
                    }
                } else {
                    result.code = 999;
                    result.message = "unknown response format." + res;
                    dispatchEvent(new URLShortenerEvent(URLShortenerEvent.ERROR, result));
                }
            } else {
                result.code = 999;
                result.message = "Response status is not OK";
                if ("errorCode" in obj) {
                    result.code = int(obj.errorCode);
                }
                if ("errorMessage" in obj) {
                    result.message = obj.errorMessage;
                }
                dispatchEvent(new URLShortenerEvent(URLShortenerEvent.ERROR, result));
            }
        }

        public function matchURI(uri:URI):Boolean
        {
            return (uri.toString().match(/^http:\/\/(?:bit.ly|j.mp)\/\S+/) == null)
                ? true : false;
        }

        public function expand(url:URI):void
        {
            if (_isFetching)
                throw new Error("fetching.");
            var urlString:String = url.toString();
            var endpoint:String;
            if (urlString.indexOf("http://bit.ly/") == 0) {
                endpoint = "http://api.bit.ly/expand";
            } else if(urlString.indexOf("http://j.mp/") == 0) {
                endpoint = "http://api.j.mp/expand";
            } else {
                throw new Error("This is not shorten url for bit.ly");
            }
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, expandCompleteHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            var reqURI:URI = new URI(endpoint);
            var queryMap:Object = new Object();
            queryMap.version = "2.0.1";
            queryMap.shortUrl = urlString;
            queryMap.apiKey = _apiKey;
            queryMap.login = _userID;
            queryMap.format = "json";
            reqURI.setQueryByMap(queryMap);
            _isFetching = true;
            _loader.load(new URLRequest(reqURI.toString()));
        }

        private function expandCompleteHandler(e:Event):void
        {
            _isFetching = false;
            var res:String = _loader.data as String;
            var obj:Object = JSON.decode(res);
            var result:URLShortenerEventResult = new URLShortenerEventResult();
            if (obj != null && "statusCode" in obj && obj.statusCode == "OK") {
                if ("results" in obj) {
                    for each(var pair:Object in obj.results) {
                        if ("longUrl" in pair) {
                            result.url = new URI(pair.longUrl);
                        }
                        break;
                    }
                    if (result.url != null) {
                        dispatchEvent(new URLShortenerEvent(URLShortenerEvent.EXPANDED, result));
                    } else {
                        result.code = 999;
                        result.message = "unknown response format." + res;
                        dispatchEvent(new URLShortenerEvent(URLShortenerEvent.ERROR, result));
                    }
                } else {
                    result.code = 999;
                    result.message = "unknown response format." + res;
                    dispatchEvent(new URLShortenerEvent(URLShortenerEvent.ERROR, result));
                }
            } else {
                result.code = 999;
                result.message = "Response status is not OK";
                if ("errorCode" in obj) {
                    result.code = int(obj.errorCode);
                }
                if ("errorMessage" in obj) {
                    result.message = obj.errorMessage;
                }
                dispatchEvent(new URLShortenerEvent(URLShortenerEvent.ERROR, result));
            }
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            _isFetching = false;
            dispatchEvent(e.clone());
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            _isFetching = false;
            dispatchEvent(e.clone());
        }
    }
}

