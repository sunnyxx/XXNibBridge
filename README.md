XXNibBridge
===========

# Overview

`XXNibBridge` bridges `xib` file to storyboards or another xib file  

Design time:  

![](http://ww2.sinaimg.cn/large/51530583gw1ehzgklik42j20m80go0ua.jpg = x500)

Runtime:  

![](http://ww3.sinaimg.cn/large/51530583gw1ehzgoiqfkfj20hs0qo75u.jpg = x500)

-----

# How to use

1. Build your class and it's xib file. (Same name required)  
    ![](http://ww3.sinaimg.cn/large/51530583gw1ei03dn8rq8j206g036q2z.jpg)
2. Put a placeholder view in target IB(xib or storyboard), Set it's class. 
    ![](http://ww1.sinaimg.cn/large/51530583gw1ei03b0vuzmj20z40a6q4e.jpg = x500)
3. Override a class method to turn on bridging.  

    ``` objc
        #import <XXNibBridge.h>
        @implementation XXDogeView
        + (BOOL)xx_shouldApplyNibBridging
        {
             return YES;
        }
        @end
    ```
    
Done:  
    ![](http://ww4.sinaimg.cn/large/51530583gw1ei03g01mmej20ga07sjrt.jpg = x500)

# How it works

中文介绍请见[我的blog](http://blog.sunnyxx.com/2014/07/01/ios_ib_bridge/)
