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
    import com.adobe.net.URI;

    /**
     * var tiny:TinyURLClient = new TinyURLClient();
     * tiny.addEventListener(...);
     * ...
     * var bitly:BitlyClient = new BitlyClient(userID, apiKey);
     * bitly.addEventListener(...);
     * ...
     * var registry:URLShortenerRegistry = new URLShortenerRegistry();
     * registry.register( tiny );
     * registry.register( bitly );
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

