describe port(80) do
    it { should be_listening  }
end

describe windows_feature('Web-Server') do
    it{ should be_installed.by("powershell")  }
end

describe iis_website("chocolateyserver") do
  it { should exist  }
  it { should be_enabled  }
  it { should be_running  }
  it { should be_in_app_pool "chocolateyserver"  }
end

describe iis_app_pool("chocolateyserver") do
  it { should exist  }
#  it { should have_dotnet_version "2.0"  }
end
