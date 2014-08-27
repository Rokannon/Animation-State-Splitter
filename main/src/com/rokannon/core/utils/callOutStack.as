package com.rokannon.core.utils
{
    import flash.utils.clearInterval;
    import flash.utils.setInterval;

    public function callOutStack(method:Function, ...args):void
    {
        var interval:uint = setInterval(function ():void
                                        {
                                            clearInterval(interval);
                                            method.apply(null, args);
                                        }, 0);
    }
}