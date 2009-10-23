package org.coderepos.webservices
{
    import com.adobe.net.URI;

    /**
     * var tiny:TinyURLClient = new TinyURLClient();
     * tiny.addEventListener(...);
     * ...
     * var bitly:BitlyClient = new BitlyClient(userID, apiKey);
     * bitly.addEventListener(...);
     * ...
     * var registry:URLShortenerRegistry = new URLShortenerRegistry();
     * regisry.register( tiny );
     * regisry.register( bitly );
     *
     * var shortener:IURLShortener =
     *     registry.getShortenerForURI(uri);
     * if (shortener == null) {
     *   trace("There isn't a proper service to expand this url.");
     * } else {
         if (!shortener.isFetching)
     *     shortener.expand(uri);
     * }
     */
    public class URLShortenerRegistry
    {
        private var _shorteners:Vector.<IURLShortener>;

        public function URLShortenerRegistry()
        {
            _shorteners = new Vector.<IURLShortener>();
        }

        public function register(client:IURLShortener):void
        {
            _shorteners.push(client);
        }

        public function getShortenerForURI(uri:URI):IURLShortener
        {
            for each(var shortener:IURLShortener in _shorteners) {
                if (shortener.matchURI(uri)) {
                    return shortener;
                }
            }
            return null;
        }
    }
}

