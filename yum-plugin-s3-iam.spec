Name:		yum-plugin-s3-iam
Version:	1.0
Release:	%{__tr_release_num}%{?dist}
Summary:	Yum package manager plugin for private S3 repositories.

Group:		Application/SystemTools
License:	Apache License Version 2.0, January 2004
URL:		https://github.com/lattwood/yum-s3-iam
Source0:	yum-plugin-s3-iam.tar.gz

BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch

Requires:	yum

%description
Yum package manager plugin for private S3 repositories.
Uses Amazon IAM & EC2 Roles.

%prep
rm -rf %{_builddir}/%{name}
mkdir %{_builddir}/%{name}
cd %{_builddir}/%{name}
gzip -dc %{_sourcedir}/yum-plugin-s3-iam.tar.gz | tar -xvvf -
if [ $? -ne 0 ]; then
	exit $?
fi

%build

%install
rm -rf $RPM_BUILD_ROOT
cd %{_builddir}/%{name}
make install DESTDIR=%{buildroot}

%clean
rm -rf ${RPM_BUILD_ROOT}

%files
%defattr(-,root,root,-)
%doc s3iam.repo
%doc LICENSE NOTICE README.md
%config /etc/yum/pluginconf.d/s3iam.conf
/usr/lib/yum-plugins/s3iam.py*

%changelog
* Wed Jun 17 2015 Logan Attwood <logan@jnickel.com> 1.0-3
Use a mock environment that exists by default.

* Mon Oct 20 2014 Logan Attwood <logan@therounds.ca> 1.0-2
Packaging modifications

* Fri May 31 2013 Matt Jamison <matt@mattjamison.com> 1.0-1
Initial packaging
