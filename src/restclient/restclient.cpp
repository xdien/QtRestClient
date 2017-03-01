#include "restclient.h"
#include "restclient_p.h"
#include "restclass.h"
#include "standardpaging.h"
#include <QtCore/QBitArray>
#include <QtCore/QCoreApplication>
#include <QtCore/QRegularExpression>
#include <QtCore/QUuid>
using namespace QtRestClient;

#define d d_ptr

RestClient::RestClient(QObject *parent) :
	QObject(parent),
	d_ptr(new RestClientPrivate(this))
{}

RestClient::~RestClient() {}

RestClass *RestClient::createClass(const QString &path, QObject *parent)
{
	return new RestClass(this, path.split(QLatin1Char('/'), QString::SkipEmptyParts), parent);
}

RestClass *RestClient::rootClass() const
{
	return d->rootClass;
}

QNetworkAccessManager *RestClient::manager() const
{
	return d->nam;
}

QJsonSerializer *RestClient::serializer() const
{
	return d->serializer;
}

PagingFactory *RestClient::pagingFactory() const
{
	return d->pagingFactory.data();
}

QUrl RestClient::baseUrl() const
{
	return d->baseUrl;
}

QVersionNumber RestClient::apiVersion() const
{
	return d->apiVersion;
}

HeaderHash RestClient::globalHeaders() const
{
	return d->headers;
}

QUrlQuery RestClient::globalParameters() const
{
	return d->query;
}

QHash<QNetworkRequest::Attribute, QVariant> RestClient::requestAttributes() const
{
	return d->attribs;
}

QSslConfiguration RestClient::sslConfiguration() const
{
	return d->sslConfig;
}

RequestBuilder RestClient::builder() const
{
	return RequestBuilder(d->nam, d->baseUrl)
			.setVersion(d->apiVersion)
			.addHeaders(d->headers)
			.addParameters(d->query)
			.setAttributes(d->attribs)
			.setSslConfig(d->sslConfig);
}

bool RestClient::addGlobalApi(const QString &name, RestClient *client)
{
	if(RestClientPrivate::globalApis.contains(name))
		return false;
	else {
		client->setParent(qApp);
		RestClientPrivate::globalApis.insert(name, client);
		return true;
	}
}

void RestClient::removeGlobalApi(const QString &name, bool deleteClient)
{
	if(deleteClient) {
		auto client = RestClientPrivate::globalApis.take(name);
		if(client)
			client->deleteLater();
	} else
		RestClientPrivate::globalApis.remove(name);
}

RestClient *RestClient::apiClient(const QString &name)
{
	return RestClientPrivate::globalApis.value(name, nullptr);
}

RestClass *RestClient::apiRootClass(const QString &name)
{
	auto client = RestClientPrivate::globalApis.value(name, nullptr);
	if(client)
		return client->rootClass();
	else
		return nullptr;
}

RestClass *RestClient::createApiClass(const QString &name, const QString &path, QObject *parent)
{
	auto client = RestClientPrivate::globalApis.value(name, nullptr);
	if(client)
		return client->createClass(path, parent);
	else
		return nullptr;
}

void RestClient::setBaseUrl(QUrl baseUrl)
{
	if (d->baseUrl == baseUrl)
		return;

	d->baseUrl = baseUrl;
	emit baseUrlChanged(baseUrl, {});
}

void RestClient::setApiVersion(QVersionNumber apiVersion)
{
	if (d->apiVersion == apiVersion)
		return;

	d->apiVersion = apiVersion;
	emit apiVersionChanged(apiVersion, {});
}

void RestClient::setGlobalHeaders(HeaderHash globalHeaders)
{
	if (d->headers == globalHeaders)
		return;

	d->headers = globalHeaders;
	emit globalHeadersChanged(globalHeaders, {});
}

void RestClient::setGlobalParameters(QUrlQuery globalParameters)
{
	if (d->query == globalParameters)
		return;

	d->query = globalParameters;
	emit globalParametersChanged(globalParameters, {});
}

void RestClient::setRequestAttributes(QHash<QNetworkRequest::Attribute, QVariant> requestAttributes)
{
	if (d->attribs == requestAttributes)
		return;

	d->attribs = requestAttributes;
	emit requestAttributesChanged(requestAttributes, {});
}

void RestClient::setModernAttributes()
{
	d->attribs.insert(QNetworkRequest::FollowRedirectsAttribute, true);
	d->attribs.insert(QNetworkRequest::HttpPipeliningAllowedAttribute, true);
	d->attribs.insert(QNetworkRequest::SpdyAllowedAttribute, true);
	d->attribs.insert(QNetworkRequest::HTTP2AllowedAttribute, true);
	emit requestAttributesChanged(d->attribs, {});
}

void RestClient::setSslConfiguration(QSslConfiguration sslConfiguration)
{
	if (d->sslConfig == sslConfiguration)
		return;

	d->sslConfig = sslConfiguration;
	emit sslConfigurationChanged(sslConfiguration, {});
}

void RestClient::addGlobalHeader(QByteArray name, QByteArray value)
{
	d->headers.insert(name, value);
	emit globalHeadersChanged(d->headers, {});
}

void RestClient::removeGlobalHeader(QByteArray name)
{
	if(d->headers.remove(name) > 0)
		emit globalHeadersChanged(d->headers, {});
}

void RestClient::addGlobalParameter(QString name, QString value)
{
	d->query.addQueryItem(name, value);
	emit globalParametersChanged(d->query, {});
}

void RestClient::removeGlobalParameter(QString name)
{
	d->query.removeQueryItem(name);
	emit globalParametersChanged(d->query, {});
}

void RestClient::addRequestAttribute(QNetworkRequest::Attribute attribute, QVariant value)
{
	d->attribs.insert(attribute, value);
	emit requestAttributesChanged(d->attribs, {});
}

void RestClient::removeRequestAttribute(QNetworkRequest::Attribute attribute)
{
	d->attribs.remove(attribute);
	emit requestAttributesChanged(d->attribs, {});
}

// ------------- Private Implementation -------------

QHash<QString, RestClient*> RestClientPrivate::globalApis;

QNetworkAccessManager *RestClientPrivate::getNam(RestClient *client)
{
	return client->d_ptr->nam;
}

RestClientPrivate::RestClientPrivate(RestClient *q_ptr) :
	baseUrl(),
	apiVersion(),
	headers(),
	query(),
	sslConfig(QSslConfiguration::defaultConfiguration()),
	nam(new QNetworkAccessManager(q_ptr)),
	serializer(new QJsonSerializer(q_ptr)),
	pagingFactory(new StandardPagingFactory()),
	rootClass(new RestClass(q_ptr, {}, q_ptr))
{}