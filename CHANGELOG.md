
## 3/17/12

Initial release.

## 3/18/12 ##

Added hooks for subclassing.

## 3/19/12 ##

Moved parent initialization to separate method (with call to initialize so existing behavior remains).
Now parent can be initialized after object initialization.

## 3/24/12 ##

Added _without_hook methods to perform actions without calling hooks.

## 3/26/12 ##

Fixed typo that broke set without hooks.

## 5/27/12 ##

Added common CompositingObject support.

## 5/31/12 ##

Added :parent_composite_object and changed :parent_array to alias :parent_composite_object.

## 6/1/12 ##

Added :configuration_instance parameter to :initialize.

## 6/15/12 ##

Moved hooks out to hooked-array and utilized hooked-array as foundation.
Fixed dependency in gemspec.

## 6/18/12 ##

Fixed index miscount.
Fixed index miscount fix for proper count.

## 7/9/2012 ##

Removed module-cluster dependency.

## 7/10/2012 ##

Reverted module-cluster dependency.

## 7/14/2012 ##

Lazy load fix for :include?

## 10/15/2012 ##

Updated to support multiple parents.

## 11/24/2012 ##

Updated for fake Array inheritance support since inheriting from Array prevents #to_a from being called at splat.

## 7/08/2013 ##

Removed module-cluster dependency so that module-cluster can use hooked and compositing objects.
