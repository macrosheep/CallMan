/*
 * Copyright (c) 2013-2014 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/system/InvokeManager>
#include <bb/cascades/ToggleButton>
#include <bb/cascades/ListView>
#include <bb/pim/phone/CallType>
#include <bb/system/phone/Phone>

using namespace bb::cascades;
using namespace bb::system;

bool initialized = false;

ApplicationUI::ApplicationUI() :
        QObject(),
        m_translator(new QTranslator(this)),
        m_localeHandler(new LocaleHandler(this)),
        m_invokeManager(new InvokeManager(this))
{
    QCoreApplication::setOrganizationName("Yang Hongyang");
    QCoreApplication::setApplicationName("CallMan");

    // prepare the localization
    if (!QObject::connect(m_localeHandler, SIGNAL(systemLanguageChanged()),
            this, SLOT(onSystemLanguageChanged()))) {
        // This is an abnormal situation! Something went wrong!
        // Add own code to recover here
        qWarning() << "Recovering from a failed connect()";
    }

    // initial load
    onSystemLanguageChanged();

    // Connect to the database
    QString path = QDir::currentPath() + "/app/native/assets/mobile.db";
    sda = new bb::data::SqlDataAccess(path);

    //create datamodel
    callLogModel = new GroupDataModel(QStringList() << "date" << "time" << "name" << "city" << "carrier" << "phoneNumber" << "callType");
    callLogModel->setGrouping(ItemGrouping::ByFullValue);
    callLogModel->setSortedAscending(false);

    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);

    // Make app available to the qml.
    qml->setContextProperty("app", this);

    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();
    initSettings();

    QSettings settings;
    root->setProperty("attrOnCall", settings.value("attribution/onCall").toBool());
    root->setProperty("attrOnConnected", settings.value("attribution/onConnected").toBool());
    root->setProperty("attrOnDisconnected", settings.value("attribution/onDisconnected").toBool());
    root->setProperty("attrHub", settings.value("attribution/hub").toBool());
    root->setProperty("vibrationOnConnected", settings.value("vibration/onConnected").toFloat());
    root->setProperty("vibrationOnDisconnected", settings.value("vibration/onDisconnected").toFloat());

    //attach datamodel
    //filterModel("missed");
    ListView *listView = root->findChild<ListView *>("callLogList");
    listView->setDataModel(callLogModel);

    //create dialog to display phone number attribution
    dialog = new SystemDialog(tr("OK"));

    // Set created root object as the application scene
    Application::instance()->setScene(root);
    initialized = true;
}

void ApplicationUI::filterModel(QString type)
{
    qint64 calltype;
    QVariantList reslist;

    currOption = type;
    if (type == "missed")
        calltype = bb::pim::phone::CallType::Missed;
    else if (type == "in")
        calltype = bb::pim::phone::CallType::Incoming;
    else if (type == "out")
        calltype = bb::pim::phone::CallType::Outgoing;
    else if (type == "all")
        calltype = -1;
    else
        return;

    switch(calltype) {
        case -1:
            reslist = sda->execute("SELECT * FROM calllog;").value<QVariantList>();
            break;
        case bb::pim::phone::CallType::Missed:
        case bb::pim::phone::CallType::Incoming:
        case bb::pim::phone::CallType::Outgoing:
            reslist = sda->execute("SELECT * FROM calllog WHERE callType = " + QString::number(calltype) +";").value<QVariantList>();
            break;
        default:
            break;
    }
    callLogModel->clear();
    if (reslist.isEmpty()) {
        return;
    }
    callLogModel->insertList(reslist);
}

void ApplicationUI::initSettings()
{
    QSettings settings;

    if (!settings.contains("attribution/onCall"))
        settings.setValue("attribution/onCall", true);
    if (!settings.contains("attribution/onConnected"))
        settings.setValue("attribution/onConnected", true);
    if (!settings.contains("attribution/onDisconnected"))
        settings.setValue("attribution/onDisconnected", false);
    if (!settings.contains("attribution/hub"))
        settings.setValue("attribution/hub", true);

    if (!settings.contains("vibration/onConnected"))
        settings.setValue("vibration/onConnected", 0.3);
    if (!settings.contains("vibration/onDisconnected"))
        settings.setValue("vibration/onDisconnected", 0.0);

    settings.sync();
    settingsWatcher = new QFileSystemWatcher(this);
    settingsWatcher->addPath(settings.fileName());
    connect(settingsWatcher,
            SIGNAL(fileChanged(const QString &)),
            this,
            SLOT(settingsChanged(const QString &)));
}

void ApplicationUI::settingsChanged(const QString & path)
{
    qDebug() << "settings changed: " << path;
    filterModel(currOption);
}

void ApplicationUI::enableAttribution(QString attr)
{
    QSettings settings;

    if (attr.compare("onCall") == 0)
        settings.setValue("attribution/onCall", true);
    else if (attr.compare("onConnected") == 0)
        settings.setValue("attribution/onConnected", true);
    else if (attr.compare("onDisconnected") == 0)
        settings.setValue("attribution/onDisconnected", true);
    else if (attr.compare("hub") == 0) {
        settings.setValue("attribution/hub", true);
        InvokeRequest request;
        request.setTarget("com.example.CallManService");
        request.setAction("com.example.CallManService.ENABLEHUB");
        m_invokeManager->invoke(request);
    } else
        return;
}

void ApplicationUI::disableAttribution(QString attr)
{
    QSettings settings;

    if (attr.compare("onCall") == 0)
        settings.setValue("attribution/onCall", false);
    else if (attr.compare("onConnected") == 0)
        settings.setValue("attribution/onConnected", false);
    else if (attr.compare("onDisconnected") == 0)
        settings.setValue("attribution/onDisconnected", false);
    else if (attr.compare("hub") == 0) {
        settings.setValue("attribution/hub", false);
        InvokeRequest request;
        request.setTarget("com.example.CallManService");
        request.setAction("com.example.CallManService.DISABLEHUB");
        m_invokeManager->invoke(request);
    } else
        return;
}

void ApplicationUI::setVibration(QString attr, QString value)
{
    QSettings settings;
    if (!initialized)
        return;

    if (attr.compare("onConnected") == 0)
        settings.setValue("vibration/onConnected", value.toFloat());
    else if (attr.compare("onDisconnected") == 0)
        settings.setValue("vibration/onDisconnected", value.toFloat());
    else
        return;

}

void ApplicationUI::onListItemTriggered(QVariantList indexPath)
{
    if (callLogModel->itemType(indexPath) == "item") {
        QVariantMap map = callLogModel->data(indexPath).value<QVariantMap>();
        QString pnum = map["phoneNumber"].toString();
        bb::system::phone::Phone phone;
        phone.initiateCellularCall(pnum);
    }
}

void ApplicationUI::clearCalllog()
{
    sda->execute("delete from \"calllog\";");
    filterModel(currOption);
}

void ApplicationUI::ivalidNumber()
{
    //show invalid number dialog
    dialog->setTitle(tr("Error"));
    dialog->setBody(tr("Please enter valid mobile number or area code!"));
    dialog->show();
}

void ApplicationUI::notFound()
{
    //show invalid number dialog
    dialog->setTitle(tr("Error"));
    dialog->setBody(tr("Phone number attribution not found!"));
    dialog->show();
}

void ApplicationUI::search(QString pnum)
{
    QString key;
    QVariantMap map;

    if (pnum == "") {
        ivalidNumber();
        return;
    }

    if (pnum.startsWith("0")) {
        //telephone number with area code
        qDebug() << "search key: " << pnum;
        QVariantList reslist = sda->execute("SELECT * FROM telephone WHERE region = \""+pnum+"\";").value<QVariantList>();
        if (reslist.isEmpty()) {
            notFound();
            return;
        }
        map = reslist[0].value<QVariantMap>();
    } else {
        //mobile number without country code
        if (pnum.size() < 7) {
            ivalidNumber();
            return;
        }
        qDebug() << "search key: " << pnum.left(7);
        QVariantList reslist = sda->execute("SELECT * FROM cellphone WHERE mobile = \""+pnum.left(7)+"\";").value<QVariantList>();
        if (reslist.isEmpty()) {
            notFound();
            return;
        }
        map = reslist[0].value<QVariantMap>();
    }

    //show phone number attribution
    dialog->setTitle(map["city"].toString());
    dialog->setBody(map["carrier"].toString());
    dialog->show();
    return;
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_translator);
    // Initiate, load and install the application translation files.
    QString locale_string = QLocale().name();
    QString file_name = QString("CallMan_%1").arg(locale_string);
    if (m_translator->load(file_name, "app/native/qm")) {
    QCoreApplication::instance()->installTranslator(m_translator);
    }
}
