# ==Description:
#
# get flash player status on Windows.
# 
# ==Author:
# 
# Zhu Sheng Li <zshengli@cn.ibm.com>

def with_key(name, &block)
  Win32::Registry::HKEY_LOCAL_MACHINE.open(name, Win32::Registry::KEY_READ | 0x100) do |reg|
    yield reg if block_given?
  end

  true
rescue
  false
end

def reg_value(path, value)
  rval = nil

  with_key(path) do |reg|
    rval = reg.read(value)
  end

  rval
end

Facter.add :flash do
  confine :kenel => :windows
  setcode do
    require Win32::Registry
    flash = {}
    flash['npapi'] = reg_value('Software\Macromedia\FlashPlayerPlugin', 'Version')
    flash['activex'] = reg_value('Software\Macromedia\FlashPlayerActiveX', 'Version')
    flash['installed'] = !!(flash['npapi'] || flash['activex'])
    flash
  end
end
