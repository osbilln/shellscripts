#!/bin/bash -e
set -x

. /etc/profile
#. /usr/bin/build_envs

function devf_search_yml {
    find . -name search.yml | while read f; do
       # first enable everything, and change data folder from /tmp/.. to /data/..
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local

       sed 's/enabled: false/enabled: true/g' $f > $f.0
        sed 's/\/tmp\//\/data\//g' $f.0 > ${f}.1
       # the enabled flag in inputConfiguration section should be disabled
       sed -e '1,/^inputConfiguration/b' -e 's/enabled: true/enabled: false/g' ${f}.1 > ${f}.2
       # after timeLineConfiguration, enable again
       sed -e '1,/^timeLineConfiguration/b' -e 's/enabled: false/enabled: true/g' ${f}.2 > ${f}.3
       # everything after hornetQServerConfiguration should be disabled
       sed -e '1,/^hornetQServerConfiguration/b' -e 's/enabled: true/enabled: false/g' ${f}.3 > ${f}.4
       sed -e '27 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.4 > ${f}.5
       sed -e '70 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.5 > ${f}.6
       sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.6 > ${f}.7
       sed -e '653 s|enabled: false|enabled: true|g' ${f}.7 > ${f}.8
       sed -e 's|reindex: true|reindex: false|g' ${f}.8 > ${f}.9
       sed 's/providerUrl.*/providerUrl: "jnp:\/\/127.0.0.1:2099"/' ${f}.9 > ${f}.10
       mv ${f}.10 ${f}
       rm $f.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9
       cp $f ${f}.local

    done
}

function devf_aws_yml {
    find . -name aws.yml | while read f; do
       # if there is a backup file, restore it
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local
       sed 's/ttl:.*/ttl: 60/g' $f > ${f}.1
       sed 's/enabled: false/enabled: true/g' ${f}.1 > ${f}.2
       sed 's/defaultCNameARecord: "app\.fluigidentity.com."/defaultCNameARecord: "app\.devfluigidentity\.com\."/g' ${f}.2 > ${f}.3
       sed 's/domain: "fluigidentity\.com"/domain: "devfluigidentity\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2WOM1R3EQUYE2"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
       cp $f ${f}.local
    done
}

function devf_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/couchbaseServerUrls=.*/couchbaseServerUrls=127.0.0.1:8091;/g' $f > ${f}.1
        sed 's/keyStoreServer=.*/keyStoreServer=127.0.0.1/g' ${f}.1 > ${f}.2
        ## Replace SearchURL
        sed 's/searchUrl=.*/searchUrl\=http:\/\/127.0.0.1:18084\/search/g' ${f}.2 > ${f}.3
        sed 's/email_admin_name=.*/email_admin_name=support@devfluigidentity.com/g' ${f}.3 > ${f}.4
        sed 's/email_admin_password=.*/email_admin_password=s\[78Q4-52331FE)/g' ${f}.4 > ${f}.5
        sed 's/smtp_host=.*/smtp_host=mail\.devfluigidentity\.com/g' ${f}.5 > ${f}.6
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.devfluigidentity\.com/g' ${f}.6 > ${f}.7
        sed 's/baseUrlForMetadata=https\:\/\/app\.fluigidentity\.com\/cloudpass\//baseUrlForMetadata=https\:\/\/app\.devfluigidentity\.com\/cloudpass\//g' ${f}.7 > ${f}.8
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.8 >  ${f}.9
        sed 's/couchbaseAdminPwd=.*/couchbaseAdminPwd=t5NjMnbgAysH/' ${f}.9 > ${f}.10
        mv ${f}.10 $f
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9
        cp ${f} $f.local
    done
}

function devf_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp ${f} ${f}.local
        # sed 's/keyStorePassword=totvslabs/keyStorePassword=M\@5\}i\%\>\<\!28\&3\)v/g' ${f} > ${f}.1
        #
        done
}

function devf_keystore_yml {
  find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed -e 's|\/data\/logs\/|\/data\/devfluigidentity-logs\/|' ${f} > ${f}.1
        sed -e '89 s/false/true/g' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        rm -rf ${f}.1  
        cp $f ${f}.local
    done
}

function devf_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/' ${f} > ${f}.0
        sed 's/fluigidentityServerUrl:.*/fluigidentityServerUrl: https\:\/\/app\.devfluigidentity\.com/' ${f}.0 > ${f}.1
        sed 's/providerUrl.*/providerUrl: "jnp:\/\/127.0.0.1:2099"/' ${f}.1 > ${f}.2
        sed -e '229 s/false/true/' ${f}.2 > ${f}.3
        sed 's/listenAddress:.*/listenAddress: 127.0.0.1/g' ${f}.3 > ${f}.4
        sed -e 's|\/data\/logs\/|\/data\/devfluigidentity-logs\/|' ${f}.4 > ${f}.5
        sed -e '255 s/false/true/g' ${f}.5 > ${f}.6
        mv ${f}.6 $f
        rm -rf ${f}.0 ${f}.1  ${f}.2 ${f}.3 ${f}.4 ${f}.5
        cp $f ${f}.local
    done
}

function devf_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/java\.naming\.provider\.url=.*/java\.naming\.provider\.url=jnp:\/\/127.0.0.1:2099/' $f > ${f}.1
        mv ${f}.1 ${f}
        cp ${f} $f.local
    done
}

function devf_adsync_yml {
    find . -name adsync.yml | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/providerUrl:.*/providerUrl: jnp:\/\/127.0.0.1:2099/' $f > ${f}.1
        sed -e 's|\/data\/logs\/|/data\/devfluigidentity-logs\/|' ${f}.1 > ${f}.2
        sed -e '292 s/false/true/g' ${f}.2 > ${f}.3
  mv ${f}.3 ${f}
        rm -rf ${f}.1 ${f}.2
        cp ${f} ${f}.local
    done
}

function devf_backend_rmi {
    find . -name rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/hostname=localhost/hostname=127.0.0.1/' $f > ${f}.1
      mv ${f}.1 ${f}
#        rm -rf ${f}.1 
        cp ${f} ${f}.local
    done
}

function devf_backend_scim {
    find . -name scim.rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/hostname=localhost/hostname=127.0.0.1/' $f > ${f}.1
        mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function devf_frontend_rmi {
    find . -name rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/hostname=localhost/hostname=127.0.0.1/' $f > ${f}.1
  mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function devf_logback_xml {
    find . -name logback.xml | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/127.0.0.1/127.0.0.1/' $f > ${f}.1
    mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function devf_post_build {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1/backend/build/config
    
    devf_keystore_properties
    devf_keystore_yml
    devf_search_yml
    devf_rest_yml
    devf_server_properties
    devf_adsync_yml
    devf_hornetq 
    devf_aws_yml
    devf_logback_xml
}

DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/data/build/fluigidentity/$2

if [ ! -e $FI_HOME ]; then
  mkdir -p $FI_HOME
fi

source utility
source devbuild

if [ $# -eq 4 ]; then
   mk_dir_build $1 $2
   pull_backend $1 $2 $3
   pull_frontend $1 $2 $4
   build_backend $1 $2 $3
   build_frontend $1 $2 $4
   devf_post_build $1 $2
   deb_package $1 $2
   copy_to_repo $1 $2
   latest $1 $2
else
    echo ""
    echo -e "\n\nUsage: $0 {branch name} {ENV: prod|qa|devf|qa1b|va} {master} {master}\n\n"
    echo -e "ex: $0 identity-1.1 qa backend:branch frontend:branch data:branch security:branch \n\n"
    echo ""
fi
