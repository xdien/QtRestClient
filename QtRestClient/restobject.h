#ifndef RESTOBJECT_H
#define RESTOBJECT_H

#include "qtrestclient_global.h"

#include <QObject>

namespace QtRestClient {

class QTRESTCLIENTSHARED_EXPORT RestObject : public QObject
{
	Q_OBJECT

public:
	Q_INVOKABLE RestObject(QObject *parent = nullptr);

	static bool equals(const RestObject *left, const RestObject *right);
	virtual bool equals(const RestObject *other) const;

	template<typename T>
	static bool listEquals(const QList<T*> &left, const QList<T*> &right);
};

}

Q_DECLARE_METATYPE(QtRestClient::RestObject*)


// ------------- Generic Implementation -------------

namespace QtRestClient {

template<typename T>
bool RestObject::listEquals(const QList<T*> &left, const QList<T*> &right)
{
	static_assert(std::is_base_of<RestObject, T>::value, "T must inherit RestObject!");
	if(left.size() != right.size())
		return false;
	else {
		for(auto i = 0; i < left.size(); i++) {
			if(!equals(left[i], right[i]))
				return false;
		}
		return true;
	}
}

}

#endif // RESTOBJECT_H
