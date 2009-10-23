package org.coderepos.webservices.events
{
    import flash.events.Event;
    import com.adobe.net.URI;

    public class URLShortenerEvent extends Event
    {
        public static const SHORTENED:String = "shortened";
        public static const EXPANDED:String = "expanded";
        public static const ERROR:String = "error";

        private var _result:URLShortenerEventResult;

        public function URLShortenerEvent(type:String, result:URLShortenerEventResult, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            _result = result;
        }

        public function get result():URLShortenerEventResult
        {
            return _result;
        }
    }
}
