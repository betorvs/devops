%define	minorversion	9.2

Name:		jetty
Version:	9.2.10.v20150310
Release:	1%{?dist}
Summary:	The Jetty Webserver and Servlet Container

Group:		Networking/Daemons
License:	Apache Software License
URL:		http://eclipse.org/jetty/
Source0:	jetty-distribution-9.2.10.v20150310.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}
AutoReqProv:	no

%description
Jetty is a 100% Java HTTP Server and Servlet Container.

%prep
%setup -q -n jetty-distribution-9.2.10.v20150310

%build


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/var/log/%{name}
mkdir -p %{buildroot}/etc/init.d/
mkdir -p %{buildroot}/opt/%{name}-%{minorversion}
#jetty-distribution-9.2.10.v20150310
cp -Rip %{_builddir}/%{name}-distribution-%{version}/{bin,lib,webapps,resources,modules,etc,start.jar,start.ini,VERSION.txt} %{buildroot}/opt/%{name}-%{minorversion}/
cp %{_sourcedir}/jetty-init %{buildroot}/etc/init.d/jetty

%clean
rm -rf %{buildroot}

%post
/bin/ln -sf /var/log/%{name} /opt/%{name}-%{minorversion}/logs
/bin/ln -sf /opt/%{name}-%{minorversion} /opt/%{name}

%postun

%files
%defattr(-,root,root,-)
/var/log/%{name}
/opt/%{name}-%{minorversion}/bin
/opt/%{name}-%{minorversion}/lib
/opt/%{name}-%{minorversion}/webapps
/opt/%{name}-%{minorversion}/resources
/opt/%{name}-%{minorversion}/modules
/opt/%{name}-%{minorversion}/etc
%attr(-,root,root)
/opt/%{name}-%{minorversion}/start.jar
/opt/%{name}-%{minorversion}/start.ini
/opt/%{name}-%{minorversion}/VERSION.txt
%attr(0755,root,root)
/etc/init.d/jetty


%changelog
* Fri Mar 19 2015 - roberto.scudeller (at) oi.net.br
- Initial release
