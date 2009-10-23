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

        public function URLShortenerEvent(type:String, result:URLShortenerEventResult,
            bubbles:Boolean=false, cancelable:Boolean=false)
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
