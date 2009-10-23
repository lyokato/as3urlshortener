package suite {
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.webservices.TinyURLClient;
    import org.coderepos.webservices.IURLShortener;
    import org.coderepos.webservices.events.URLShortenerEvent;

    import flash.events.IOErrorEvent;

    import com.adobe.net.URI;

    public class TinyURLTest extends TestCase {

        private var tiny:IURLShortener;

        public function TinyURLTest(meth:String) {
            super(meth);
        }

        public static function suite():TestSuite {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new TinyURLTest("testShorten"));
            ts.addTest(new TinyURLTest("testExpand"));
            return ts;
        }

        public function testShorten():void
        {
            tiny = new TinyURLClient();
            tiny.addEventListener(URLShortenerEvent.SHORTENED, addAsync(shortenedHandler, 10000));
            //tiny.addEventListener(URLShortenerEvent.ERROR, addAsync(errorHandler, 10000));
            //tiny.addEventListener(IOErrorEvent.IO_ERROR, addAsync(ioErrorHandler, 10000));
            tiny.shorten(new URI("http://example.org/example"));
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
            assertEquals('http://tinyurl.com/ykbyywm', url.toString());
        }

        public function testExpand():void
        {
            tiny = new TinyURLClient();
            tiny.addEventListener(URLShortenerEvent.EXPANDED, addAsync(expandedHandler, 10000));
            tiny.expand(new URI("http://tinyurl.com/ykbyywm"));
        }

        public function expandedHandler(e:URLShortenerEvent):void
        {
            var url:URI = e.result.url;
            assertEquals('http://example.org/example', url.toString());
        }
    }
}
