# v0.2.2

* 2019-12-16 [6f4f370](../../commit/6f4f370) - __(ZhidkovDenis)__ Release 0.2.2 
* 2019-12-16 [d25637b](../../commit/d25637b) - __(ZhidkovDenis)__ fix: separate test and release sections in drone config 
* 2019-12-02 [94932dc](../../commit/94932dc) - __(ZhidkovDenis)__ Release 0.2.1 
* 2019-12-02 [e842c9f](../../commit/e842c9f) - __(ZhidkovDenis)__ fix: add missed definition for Slaver::Proxy#respond_to_missing? 
Slaver::Proxy#respond_to? now will check if Slaver::Proxy#safe_connection
could respond to specified method.

* 2019-12-02 [29081ac](../../commit/29081ac) - __(ZhidkovDenis)__ chore: remove old rails and ruby support, actualize .drone.yml 
* 2016-12-27 [7cb588c](../../commit/7cb588c) - __(Denis Korobicyn)__ chore: add dip & drone 

# v0.2.0

* 2016-12-14 [019562a](../../commit/019562a) - __(TamarinEA)__ feat: support rails 4 
* 2015-11-24 [12c8036](../../commit/12c8036) - __(Denis Korobitcin)__ Release 0.0.2 
* 2015-11-23 [a93dd20](../../commit/a93dd20) - __(Denis Korobitcin)__ chore(readme): within method and some spelling [skip ci] 
* 2015-11-23 [f186f6c](../../commit/f186f6c) - __(Denis Korobitcin)__ fix(slavable): special methods capability 

# v0.0.1

* 2015-11-03 [172eda3](../../commit/172eda3) - __(Denis Korobitcin)__ fix(slavable): add block support 
* 2015-10-22 [b67f807](../../commit/b67f807) - __(Denis Korobitcin)__ feature: added slavable extension 
* 2015-10-23 [9dc8cf0](../../commit/9dc8cf0) - __(Denis Korobitcin)__ chore(readme): fixed within section [skip ci] 
* 2015-10-22 [bbb2535](../../commit/bbb2535) - __(Denis Korobitcin)__ chore: Big refactoring 
Changes:
1. `on` now working throught `within`
2. For `within` config independent of class on which it used
3. Moved all logic to different classes
  3.1. pools -> PoolsHandler
  3.2. config -> ConfigHandler
  3.3. `on` now creaating ScopeProxy which send all missing_methods to base class with within block

* 2015-10-19 [b64de51](../../commit/b64de51) - __(Denis Korobitcin)__ feature: added main slaver logic 
* 2015-10-19 [4441efa](../../commit/4441efa) - __(Artem Napolskih)__ Initial commit 
