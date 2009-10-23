package org.coderepos.webservices
{
    import flash.events.IEventDispatcher;
    import com.adobe.net.URI;

    public interface IURLShortener extends IEventDispatcher
    {
        function matchURI(uri:URI):Boolean;
        function get isFetching():Boolean;
        function shorten(uri:URI):void;
        function expand(uri:URI):void;
    }
}

