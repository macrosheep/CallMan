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

#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/data/SqlDataAccess>
#include <bb/system/SystemDialog>
#include <bb/cascades/GroupDataModel>
#include <QFileSystemWatcher>

namespace bb {
    namespace cascades {
        class LocaleHandler;
    }
    namespace system {
        class InvokeManager;
    }
}

class QTranslator;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class ApplicationUI: public QObject
{
    Q_OBJECT
public:
    ApplicationUI();
    virtual ~ApplicationUI() { }

    Q_INVOKABLE void enableAttribution(QString);
    Q_INVOKABLE void disableAttribution(QString);
    Q_INVOKABLE void setVibration(QString attr, QString value);
    Q_INVOKABLE void search(QString);
    Q_INVOKABLE void filterModel(QString);
    Q_INVOKABLE void onListItemTriggered(QVariantList);
    Q_INVOKABLE void clearCalllog();

private slots:
    void onSystemLanguageChanged();
    void settingsChanged(const QString &);

private:
    void ivalidNumber();
    void notFound();
    void initSettings();

    QTranslator* m_translator;
    bb::cascades::LocaleHandler* m_localeHandler;
    bb::system::InvokeManager* m_invokeManager;

    bb::data::SqlDataAccess * sda;
    bb::system::SystemDialog * dialog;
    bb::cascades::GroupDataModel * callLogModel;

    QFileSystemWatcher* settingsWatcher;
    QString currOption;
};

#endif /* ApplicationUI_HPP_ */
