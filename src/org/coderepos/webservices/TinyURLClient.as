/*
Copyright (c) Lyo Kato (lyo.kato _at_ gmail.com)

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
*/

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
    import com.adobe.utils.StringUtil;

    import org.httpclient.HttpResponse;
    import org.httpclient.HttpClient;

    import org.httpclient.http.Get;

    import org.httpclient.events.HttpResponseEvent;
    import org.httpclient.events.HttpDataEvent;
    import org.httpclient.events.HttpResponseEvent;
    import org.httpclient.events.HttpStatusEvent;


    import org.coderepos.webservices.events.URLShortenerEvent;
    import org.coderepos.webservices.events.URLShortenerEventResult;

    /*
     * import org.coderepos.webservices.TinyURL;
     * import org.coderepos.webservices.IURLShortener;
     * import org.coderepos.webservices.events.URIShortenerEvent;
     * import com.adobe.net.URI;
     *
     * import flash.events.IOErrorEvent;
     * import flash.events.SecurityErrorEvent;
     *
     * var tiny:IURLShortener = new TinyURLClient();
     * tiny.addEventListener(URIShortenerEvent.SHORTENED,
     *     shortenCompleteHandler);
     * tiny.addEventListener(URIShortenerEvent.EXPANDED,
     *     expandedCompleteHandler);
     * tiny.addEventListener(URIShortenerEvent.ERROR, errorHandler);
     * tiny.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
     * tiny.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
     *
     * if (!tiny.isFetching && tiny.matchURI(originalURL)) {
     *     tiny.shorten(originalURL);
     * }
     *
     * private function shortenCompleteHandler(e:URIShortenerEvent):void
     * {
     *     vr shortenedURL:URI = e.result.url;
     * }
     *
     * private function errorHandler(e:ErrorEvent):void
     * {
     *    trace(e.toString());
     * }
     *
     * if (!tiny.isFetching && tiny.matchURI(shortenedURL)) {
     *   tiny.expand(shortendedURL);
     * }
     *
     *
     * private function expandedCompleteHandler(e:URLShortenerEvent):void {
     *    var originalURL:URI = e.result.url;
     * }
     *
     */

    public class TinyURLClient extends EventDispatcher implements IURLShortener
    {
        private var _loader:URLLoader;
        private var _http:HttpClient;
        private var _isFetching:Boolean;
        private var _lastLocation:String;

        public function TinyURLClient()
        {
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
            var reqURI:URI = new URI("http://tinyurl.com/api-create.php");
            var queryMap:Object = new Object();
            queryMap.url = url.toString();
            reqURI.setQueryByMap(queryMap);
            _isFetching = true;
            _loader.load(new URLRequest(reqURI.toString()));
        }

        private function shortenCompleteHandler(e:Event):void
        {
            _isFetching = false;
            var res:String = _loader.data as String;
            var result:URLShortenerEventResult = new URLShortenerEventResult();
            if (res.match(/^http:\/\/tinyurl.com\/\S+$/)) {
                result.url = new URI(res);
                dispatchEvent(new URLShortenerEvent(URLShortenerEvent.SHORTENED, result));
            } else {
                dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "invalid response"));
            }
        }

        public function matchURI(uri:URI):Boolean
        {
            return ( uri.toString().match(/^http:\/\/tinyurl.com\/\S+/) )
                ? true : false;
        }

        public function expand(url:URI):void
        {
            if (_isFetching)
                throw new Error("fetching.");
            var urlString:String = url.toString();
            if (!matchURI(url))
                throw new Error("This is not shorten url for TinyURL.");

            _http = new HttpClient();
            _http.listener.onClose = httpCloseHandler;
            _http.listener.onComplete = expandCompleteHandler;
// response body is not required, we need only Location header.
//            _http.listener.onData = httpDataHandler;
            _http.listener.onError = httpErrorHandler;
            _http.listener.onStatus = httpStatusHandler;
            _http.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _http.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _isFetching = true;
            _http.request(url, new Get());
        }

        private function httpStatusHandler(e:HttpStatusEvent):void
        {
            _lastLocation = e.response.header.getValue("Location");
        }

        private function httpCloseHandler(e:Event):void
        {
            _isFetching = false;
            _http.cancel();
        }

        private function httpErrorHandler(e:ErrorEvent):void
        {
            _isFetching = false;
            _http.cancel();
            dispatchEvent(e.clone());
        }

        /*
        private function httpDataHandler(e:HttpDataEvent):void
        {

        }
        */

        private function expandCompleteHandler(e:HttpResponseEvent):void
        {
            _isFetching = false;
            var result:URLShortenerEventResult = new URLShortenerEventResult();
            if (_lastLocation != null) {
                result.url = new URI(StringUtil.trim(_lastLocation));
                dispatchEvent(new URLShortenerEvent(URLShortenerEvent.EXPANDED, result));
            } else {
                result.message = "Invalid response";
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

