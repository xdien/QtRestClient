#ifndef CLASSBUILDER_H
#define CLASSBUILDER_H

#include "restbuilder.h"

class ClassBuilder : public RestBuilder
{
	Q_OBJECT

public:
	ClassBuilder();

private:
	struct MethodInfo {
		struct Parameter {
			QString type;
			QString name;
			QString defaultValue;

			Parameter(const QString &data);
			QString write(bool withDefault) const;
		};

		QString path;
		QString url;
		QString verb;
		QList<Parameter> pathParams;
		QList<Parameter> parameters;
		QHash<QString, QString> headers;
		QString body;
		QString returns;
		QString except;

		MethodInfo();
	};

	QHash<QString, QString> classes;
	QHash<QString, MethodInfo> methods;
	QString defaultExcept;

	void build() override;
	QString specialPrefix() override;

	static QString expr(const QString &expression, bool stringLiteral);

	void generateClass();
	void generateApi();

	void writeClassBeginDeclaration(const QString &parent);
	void writeClassMainDeclaration();
	void writeClassBeginDefinition();
	void writeClassMainDefinition(const QString &parent);

	void readClasses();
	void readMethods();

	void generateFactoryDeclaration();
	void writeFactoryDeclarations();
	void writeClassDeclarations();
	void writeMethodDeclarations();
	void writeMemberDeclarations();
	void generateFactoryDefinition();
	void writeFactoryDefinitions();
	void writeClassDefinitions();
	void writeMethodDefinitions();
	void writeMemberDefinitions();

	void writeLocalApiGeneration();
	void writeGlobalApiGeneration(const QString &globalName);
	void writeApiCreation();

	bool writeMethodPath(const MethodInfo &info);
};

#endif // CLASSBUILDER_H
