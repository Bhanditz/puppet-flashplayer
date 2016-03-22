# flashplayer

Puppet module for automatically updating flash player with a self-established
internal distribution server.

------

## How to Use

You have to establish a distribution server first. For detailed How-To,
please refer to section *Performing a background update* under *Chapter 3* of [administration guide](http://www.adobe.com/devnet/flashplayer/articles/flash_player_admin_guide.html). 


```puppet
class { 'flashplayer':
  server => 'example.domain.com',
  cert_base64_string => 'base64 string',
  installer_source => '\\10.1.1.111\flash'
}
```

## Custom Facts

```javascript
flash => { "npapi"=>"19.0.0.226", "activex"=>nil, "installed"=>true }
```

Explain:
```
installed => if any kind of flash plugin is installed, return true, else return false.

npapi     => if NPAPI plugin is installed, return the detailed version number, else return nil.

activex   => if ActiveX plugin is installed, return the detailed version number, else return nil.
```