Name:		jre6		
Version:	1.6.0_45
Release:	1%{?dist}
Summary:	Java(TM) Platform Standard Edition Runtime Environment

Group:		Development/Tools
License:	Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. Also under other license(s) as shown at the Description field.
URL:		http://www.oracle.com/technetwork/java/javase/overview/index.html
Source0:	jre-1.6.0_45.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}
AutoReqProv:	no

%description
The Java Platform Standard Edition Runtime Environment (JRE) contains
everything necessary to run applets and applications designed for the
Java platform. This includes the Java virtual machine, plus the Java
platform classes and supporting files.
The JRE is freely redistributable, per the terms of the included license.

%prep
%setup -q

%build


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/java/jre6-1.6.0_45
cp -Rip %{_builddir}/%{name}-%{version}/{bin,javaws,lib,man,plugin} %{buildroot}/usr/java/jre6-1.6.0_45

%clean
rm -rf %{buildroot}

%post
/bin/ln -sf /usr/java/jre6-1.6.0_45/bin/java /usr/java/jre6

%postun
/bin/rm -f /usr/java/jre6
/bin/rm -rf /usr/java/jre6-1.6.0_45

%files
%defattr(-,root,root,-)
/usr/java/jre6-1.6.0_45/bin
/usr/java/jre6-1.6.0_45/javaws
/usr/java/jre6-1.6.0_45/lib
/usr/java/jre6-1.6.0_45/man
/usr/java/jre6-1.6.0_45/plugin

%changelog
* Fri Mar 13 2015 - roberto.scudeller (at) oi.net.br
- Initial release
