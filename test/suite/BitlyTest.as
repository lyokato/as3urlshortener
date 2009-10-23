package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.webservices.BitlyClient;
    import org.coderepos.webservices.IURLShortener;
    import org.coderepos.webservices.events.URLShortenerEvent;

    import flash.events.IOErrorEvent;

    import com.adobe.net.URI;

    public class BitlyTest extends TestCase {

        private var bitly:IURLShortener;
        private var userID:String = "";
        private var apiKey:String = "";

        public function BitlyTest(meth:String) {
            super(meth);
        }

        public static function suite():TestSuite {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new BitlyTest("testShorten"));
            ts.addTest(new BitlyTest("testExpand"));
            return ts;
        }

        public function testShorten():void
        {
            bitly = new BitlyClient(userID, apiKey);
            bitly.addEventListener(URLShortenerEvent.SHORTENED, addAsync(shortenedHandler, 10000));
            //bitly.addEventListener(URLShortenerEvent.ERROR, addAsync(errorHandler, 10000));
            //bitly.addEventListener(IOErrorEvent.IO_ERROR, addAsync(ioErrorHandler, 10000));
            bitly.shorten(new URI("http://example.org/example"));
        }

        public function errorHandler(e:URLShortenerEvent):void {
            assertEquals('', e.result.message);
        }

        public function ioErrorHandler(e:IOErrorEvent):void
        {
            assertEquals('', e.toString());
        }

        public function shortenedHandler(e:URLShortenerEvent):void
        {
            var url:URI = e.result.url;
            assertEquals('http://j.mp/1gf4Y5', url.toString());
        }

        public function testExpand():void
        {
            bitly = new BitlyClient(userID, apiKey);
            bitly.addEventListener(URLShortenerEvent.EXPANDED, addAsync(expandedHandler, 10000));
            bitly.expand(new URI("http://j.mp/1gf4Y5"));
        }

        public function expandedHandler(e:URLShortenerEvent):void
        {
            var url:URI = e.result.url;
            assertEquals('http://example.org/example', url.toString());
        }
    }
}
