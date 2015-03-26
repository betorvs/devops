Name:		confluence
Version:	5.7.1
Release:	1%{?dist}
Summary:	Confluence Team Collaboration Documents
Group:		Development/Tools
License:	Non free
URL:		https://confluence.atlassian.com
Source0:	atlassian-confluence-5.7.1.tar.gz
BuildRoot:	%{_topdir}/%{_tmppath}/%{name}-%{version}-%{release}
BuildArch:	noarch
Prefix:		/opt
Requires:	jdk
Requires(pre): shadow-utils
Requires(postun): shadow-utils

%description
Confluence Team Collaboration Documents

%prep
%setup -q -n atlassian-%{name}-%{version}

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/confluence
mkdir -p %{buildroot}/etc/init.d/
mkdir -p %{buildroot}/var/log/confluence/
cp -Rip %{_builddir}/atlassian-%{name}-%{version}/{bin,conf,confluence,lib,temp,webapps,work} %{buildroot}/opt/confluence
cp %{_sourcedir}/confluence-init %{buildroot}/etc/init.d/confluence
cp %{_sourcedir}/confluence-bin-user.sh %{buildroot}/opt/confluence/bin/user.sh

%pre
getent group confluence > /dev/null || /usr/sbin/groupadd -r -g 700 confluence
getent passwd confluence > /dev/null || /usr/sbin/useradd -r -g confluence -u 700 -s /sbin/nologin confluence

%clean
rm -rf %{buildroot}

%postun
/usr/sbin/userdel confluence
/usr/sbin/groupdel confluence

%post
/bin/ln -sf /var/log/confluence /opt/confluence/logs
/bin/sed -i '27s/^/confluence.home=\/opt\/confluence\//' /opt/confluence/confluence/WEB-INF/classes/confluence-init.properties

%files
%defattr(-,confluence,confluence,-)
%dir /opt/confluence
/var/log/confluence
/opt/confluence/bin
/opt/confluence/conf
/opt/confluence/confluence
/opt/confluence/lib
/opt/confluence/temp
/opt/confluence/webapps
/opt/confluence/work
%defattr(0755,root,root)
/etc/init.d/confluence


%changelog
* Thu Mar 12 2015 - roberto.scudeller (at) oi.net.br
- First package for Confluence
