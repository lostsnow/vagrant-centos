Vagrant.configure('2') do |config|
  Pathname.glob('*.json').sort.each do |template|
    name = template.basename('.json').to_s
    host = name.gsub(/[.]/, '_')
    config.vm.define host do |c|
      c.vm.box = name
      c.vm.provider :virtualbox do |vbox|
        vbox.name = name
      end
    end
  end
end
