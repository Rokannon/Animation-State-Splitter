package com.rokannon.core.utils
{
    public function requireProperty(data:Object, name:String):*
    {
        if (!data.hasOwnProperty(name))
        {
            throw new Error("Property not found: " + name);
        }
        return data[name];
    }
}