﻿
#Region Constants

Var Keywords;         // enum
Var Tokens;           // enum
Var Nodes;            // enum
Var SelectKinds;      // enum
Var Directives;       // enum
Var PrepInstructions; // enum
Var PrepSymbols;      // enum
Var BasicLitNoString; // array (one of Tokens)
Var RelOperators;     // array (one of Tokens)
Var AddOperators;     // array (one of Tokens)
Var MulOperators;     // array (one of Tokens)
Var InitOfExpression; // array (one of Tokens)
Var EmptyArray;       // array
Var TokenMap;         // map[string] (string)
Var AlphaDigitMap;    // map[string] (string)
Var Alpha, Digit;     // string

#EndRegion // Constants

#Region Settings

Var Verbose Export;  // boolean
Var Debug Export;    // boolean
Var Location Export; // boolean

#EndRegion // Settings

#Region ParserState

Var Parser_Source;    // string
Var Parser_Len;       // number
Var Parser_Line;      // number
Var Parser_EndLine;   // number
Var Parser_Pos;       // number
Var Parser_BegPos;    // number
Var Parser_EndPos;    // number
Var Parser_Char;      // string
Var Parser_Tok;       // string (one of Tokens)
Var Parser_Lit;       // string
Var Parser_Val;       // number, string, date, boolean, undefined, null
Var Parser_Scope;     // structure (Scope)
Var Parser_Vars;      // structure as map[string] (VarMod, VarLoc)
Var Parser_Methods;   // structure as map[string] (Func, Proc)
Var Parser_Unknown;   // structure as map[string] (Unknown)
Var Parser_IsFunc;    // boolean
Var Parser_AllowVar;  // boolean
Var Parser_Directive; // string (one of Directives)
Var Parser_Interface; // array (Func, Proc)
Var Parser_Comments;  // map[number] (string)

#EndRegion // ParserState

#Region VisitorState

Var Visitor_Hooks;    // structure as map[string] (array)
Var Visitor_Stack;    // structure
Var Visitor_Counters; // structure as map[string] (number)

#EndRegion // VisitorState

#Region Init

Procedure Init()
	Var Letters, Index, Char;

	Verbose = False;
	Debug = False;
	Location = True;

	InitEnums();

	BasicLitNoString = New Array;
	BasicLitNoString.Add(Tokens.Number);
	BasicLitNoString.Add(Tokens.DateTime);
	BasicLitNoString.Add(Tokens.True);
	BasicLitNoString.Add(Tokens.False);
	BasicLitNoString.Add(Tokens.Undefined);
	BasicLitNoString.Add(Tokens.Null);

	RelOperators = New Array;
	RelOperators.Add(Tokens.Eql);
	RelOperators.Add(Tokens.Neq);
	RelOperators.Add(Tokens.Lss);
	RelOperators.Add(Tokens.Gtr);
	RelOperators.Add(Tokens.Leq);
	RelOperators.Add(Tokens.Geq);

	AddOperators = New Array;
	AddOperators.Add(Tokens.Add);
	AddOperators.Add(Tokens.Sub);

	MulOperators = New Array;
	MulOperators.Add(Tokens.Mul);
	MulOperators.Add(Tokens.Div);
	MulOperators.Add(Tokens.Mod);

	InitOfExpression = New Array;
	InitOfExpression.Add(Tokens.Add);
	InitOfExpression.Add(Tokens.Sub);
	InitOfExpression.Add(Tokens.Not);
	InitOfExpression.Add(Tokens.Ident);
	InitOfExpression.Add(Tokens.Lparen);
	InitOfExpression.Add(Tokens.Number);
	InitOfExpression.Add(Tokens.String);
	InitOfExpression.Add(Tokens.StringBeg);
	InitOfExpression.Add(Tokens.DateTime);
	InitOfExpression.Add(Tokens.Ternary);
	InitOfExpression.Add(Tokens.New);
	InitOfExpression.Add(Tokens.True);
	InitOfExpression.Add(Tokens.False);
	InitOfExpression.Add(Tokens.Undefined);
	InitOfExpression.Add(Tokens.Null);

	EmptyArray = New Array;

	Alpha = "Alpha";
	Digit = "Digit";

	TokenMap = New Map;
	AlphaDigitMap = New Map;

	Letters = (
		"abcdefghijklmnopqrstuvwxyz" +
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
		"абвгдеёжзийклмнопрстуфхцчшщъыьэюя" +
		"АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
	);
	Index = 1;
	Char = "_";
	While Char <> "" Do
		TokenMap[Char] = Alpha;
		AlphaDigitMap[Char] = Alpha;
		Char = Mid(Letters, Index, 1);
		Index = Index + 1;
	EndDo;

	For Index = 0 To 9 Do
		TokenMap[String(Index)] = Digit;
		AlphaDigitMap[String(Index)] = Digit;
	EndDo;

	TokenMap[""""] = Tokens.String;
	TokenMap["|"] = Tokens.String;
	TokenMap["'"] = Tokens.DateTime;
	TokenMap["="] = Tokens.Eql;
	TokenMap["+"] = Tokens.Add;
	TokenMap["-"] = Tokens.Sub;
	TokenMap["*"] = Tokens.Mul;
	TokenMap["%"] = Tokens.Mod;
	TokenMap["("] = Tokens.Lparen;
	TokenMap[")"] = Tokens.Rparen;
	TokenMap["["] = Tokens.Lbrack;
	TokenMap["]"] = Tokens.Rbrack;
	TokenMap["?"] = Tokens.Ternary;
	TokenMap[","] = Tokens.Comma;
	TokenMap["."] = Tokens.Period;
	TokenMap[":"] = Tokens.Colon;
	TokenMap[";"] = Tokens.Semicolon;
	TokenMap[""] = Tokens.Eof;

EndProcedure // Init()

Procedure InitEnums()
	Keywords = Keywords();
	Tokens = Tokens(Keywords);
	Nodes = Nodes();
	SelectKinds = SelectKinds();
	Directives = Directives();
	PrepInstructions = PrepInstructions();
	PrepSymbols = PrepSymbols();
EndProcedure // InitEnums()

#EndRegion // Init

#Region Enums

Function Keywords() Export
	Return Enum(New Structure,
		"If.Если, Then.Тогда, ElsIf.ИначеЕсли, Else.Иначе, EndIf.КонецЕсли,
		|For.Для, Each.Каждого, In.Из, To.По, While.Пока, Do.Цикл, EndDo.КонецЦикла,
		|Procedure.Процедура, EndProcedure.КонецПроцедуры, Function.Функция, EndFunction.КонецФункции,
		|Var.Перем, Val.Знач, Return.Возврат, Continue.Продолжить, Break.Прервать,
		|And.И, Or.Или, Not.Не,
		|Try.Попытка, Except.Исключение, Raise.ВызватьИсключение, EndTry.КонецПопытки,
		|New.Новый, Execute.Выполнить, Export.Экспорт, Goto.Перейти,
		|True.Истина, False.Ложь, Undefined.Неопределено, Null"
	);
EndFunction // Keywords()

Function Tokens(Keywords = Undefined) Export
	Var Tokens;

	If Keywords = Undefined Then
		Keywords = Keywords();
	EndIf;

	Tokens = Enum(New Structure(Keywords),

		// Literals

		"Ident, Number, String, DateTime,
		// parts of strings
		|StringBeg, StringMid, StringEnd,

		// Operators

		// =   <>    <    >   <=   >=    +    -    *    /    %
		|Eql, Neq, Lss, Gtr, Leq, Geq, Add, Sub, Mul, Div, Mod,
		//    (       )       [       ]
		|Lparen, Rparen, Lbrack, Rbrack,
		//     ?      ,       .      :          ;
		|Ternary, Comma, Period, Colon, Semicolon,

		// Preprocessor instructions
		|_If, _ElsIf, _Else, _EndIf, _Region, _EndRegion, _Use,

		// Other

		//         //          &      ~
		|Eof, Comment, Directive, Label"

	);

	Return Tokens;
EndFunction // Tokens()

Function Nodes() Export
	Return Enum(New Structure,
		"Module, Unknown, Func, Proc, VarMod, VarLoc, Param,
		|VarModDecl, VarLocDecl, ProcDecl, FuncDecl,
		|BasicLitExpr, SelectExpr, DesigExpr, UnaryExpr, BinaryExpr,
		|NewExpr, TernaryExpr, ParenExpr, NotExpr, StringExpr,
		|AssignStmt, ReturnStmt, BreakStmt, ContinueStmt, RaiseStmt, ExecuteStmt, WhileStmt,
		|ForStmt, ForEachStmt, TryStmt, GotoStmt, LabelStmt, CallStmt, IfStmt, ElsIfStmt,
		|PrepIfInst, PrepElsIfInst, PrepElseInst, PrepEndIfInst, PrepRegionInst, PrepEndRegionInst,
		|PrepBinaryExpr, PrepNotExpr, PrepSymExpr, PrepUseInst"
	);
EndFunction // Nodes()

Function SelectKinds() Export
	Return Enum(New Structure,
		"Ident," // Something._
		"Index," // Something[_]
		"Call"   // Something(_)
	);
EndFunction // SelectKinds()

Function Directives() Export
	Return Enum(New Structure,
		"AtClient.НаКлиенте,"
		"AtServer.НаСервере,"
		"AtServerNoContext.НаСервереБезКонтекста,"
		"AtClientAtServerNoContext.НаКлиентеНаСервереБезКонтекста,"
		"AtClientAtServer.НаКлиентеНаСервере"
	);
EndFunction // Directives()

Function PrepInstructions() Export
	Return Enum(New Structure,
		"If.Если,"
		"ElsIf.ИначеЕсли,"
		"Else.Иначе,"
		"EndIf.КонецЕсли,"
		"Region.Область,"
		"EndRegion.КонецОбласти,"
		"Use.Использовать" // onescript
	);
EndFunction // PrepInstructions()

Function PrepSymbols() Export
	Return Enum(New Structure,
		"Client.Клиент,"
		"AtClient.НаКлиенте,"
		"AtServer.НаСервере,"
		"MobileAppClient.МобильноеПриложениеКлиент,"
		"MobileAppServer.МобильноеПриложениеСервер,"
		"ThickClientOrdinaryApplication.ТолстыйКлиентОбычноеПриложение,"
		"ThickClientManagedApplication.ТолстыйКлиентУправляемоеПриложение,"
		"Server.Сервер,"
		"ExternalConnection.ВнешнееСоединение,"
		"ThinClient.ТонкийКлиент,"
		"WebClient.ВебКлиент"
	);
EndFunction // PrepSymbols()

Function Enum(Structure, Keys)
	Var Items, Item, ItemList, Value;

	For Each Items In StrSplit(Keys, ",", False) Do
		ItemList = StrSplit(Items, ".", False);
		Value = TrimAll(ItemList[0]);
		For Each Item In ItemList Do
			Structure.Insert(TrimAll(Item), Value);
		EndDo;
	EndDo;

	Return New FixedStructure(Structure);
EndFunction // Enum()

#EndRegion // Enums

#Region AbstractSyntaxTree

Function Module(Decls, Auto, Statements, Interface, Comments)
	// Корень AST. Узел хранит информацию о модуле в целом.
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Decls,"     // array (one of #Declarations)
		"Auto,"      // array (VarLoc)
		"Body,"      // array (one of #Statements)
		"Interface," // array (Func, Proc)
		"Comments"   // map[number] (string)
	, Nodes.Module, Decls, Auto, Statements, Interface, Comments);
EndFunction // Module()

#Region Scope

Function Scope(Outer)
	Return New Structure(
		"Outer,"   // undefined, structure (Scope)
		"Objects," // structure as map[string] (Unknown, Func, Proc, VarMod, VarLoc, Param)
		"Auto"     // array (VarLoc)
	, Outer, New Structure, New Array);
EndFunction // Scope()

Function Unknown(Name)
	// Узел хранит информацию об идентификаторе, для которого не удалось
	// обнаружить объект (переменную, метод) в определенной области видимости.
	// Является объектом области видимости.
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Name"  // string
	, Nodes.Unknown, Name);
EndFunction // Unknown()

Function Func(Name, Directive, Params, Exported)
	// Узел хранит информацию о функции.
	// Является объектом области видимости.
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Name,"      // string
		"Directive," // string (one of Directives)
		"Params,"    // array (Param)
		"Export"     // boolean
	, Nodes.Func, Name, Directive, Params, Exported);
EndFunction // Func()

Function Proc(Name, Directive, Params, Exported)
	// Узел хранит информацию о процедуре.
	// Является объектом области видимости.
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Name,"      // string
		"Directive," // string (one of Directives)
		"Params,"    // array (Param)
		"Export"     // boolean
	, Nodes.Proc, Name, Directive, Params, Exported);
EndFunction // Proc()

Function VarMod(Name, Directive, Exported)
	// Узел хранит информацию о переменной уровня модуля.
	// Является объектом области видимости.
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Name,"      // string
		"Directive," // string (one of Directives)
		"Export"     // boolean
	, Nodes.VarMod, Name, Directive, Exported);
EndFunction // VarMod()

Function VarLoc(Name, Auto = False)
	// Узел хранит информацию о локальной переменной.
	// Является объектом области видимости.
	// Поле "Auto" равно истине если это авто-переменная.
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Name," // string
		"Auto"  // boolean
	, Nodes.VarLoc, Name, Auto);
EndFunction // VarLoc()

Function Param(Name, ByVal, Value = Undefined)
	// Узел хранит информацию о параметре функции или процедуры.
	// Является объектом области видимости.
	// Поле "ByVal" равно истине если параметр передается по значению.
	// Поле "Value" хранит значение параметра по умолчанию.
	// Если оно равно Неопределено, то значение не задано.
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Name,"  // string
		"ByVal," // boolean
		"Value"  // undefined, structure (UnaryExpr, BasicLitExpr)
	, Nodes.Param, Name, ByVal, Value);
EndFunction // Param()

#EndRegion // Scope

#Region Declarations

Function VarModDecl(Directive, VarList, Place = Undefined)
	// Хранит информацию об инструкции объявления переменных уровня модуля.
	// Пример:
	// <pre>
	// &НаКлиенте            // поле "Directive"
	// Перем П1 Экспорт, П2; // поле "List"
	// </pre>
	Return New Structure( // @Node
		"Type,"      // string (one of Nodes)
		"Directive," // string (one of Directives)
		"List,"      // array (VarMod)
		"Place"      // undefined, structure (Place)
	, Nodes.VarModDecl, Directive, VarList, Place);
EndFunction // VarModDecl()

Function VarLocDecl(VarList, Place = Undefined)
	// Хранит информацию об инструкции объявления локальных переменных.
	// Пример:
	// <pre>
	// Перем П1, П2; // поле "List"
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"List,"  // array (VarLoc)
		"Place"  // undefined, structure (Place)
	, Nodes.VarLocDecl, VarList, Place);
EndFunction // VarLocDecl()

Function ProcDecl(Object, Decls, Auto, Body, Place = Undefined)
	// Хранит информацию об инструкции объявления процедуры.
	// Директива и признак экспорта хранятся в поле-узле "Object",
	// который является объектом области видимости представляющим эту процедуру.
	// Пример:
	// <pre>
	// &НаКлиенте
	// Процедура Тест() Экспорт
	//     Перем П1;    // поле "Decls" хранит объявления переменных.
	//     П1 = 2;      // поле "Body" хранит операторы.
	//     П2 = П1 + 2; // Авто-переменные (П2) собираются в поле "Auto".
	// КонецПроцедуры
	// </pre>
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Object," // structure (Proc)
		"Decls,"  // array (one of #Declarations)
		"Auto,"   // array (VarLoc)
		"Body,"   // array (one of #Statements)
		"Place"   // undefined, structure (Place)
	, Nodes.ProcDecl, Object, Decls, Auto, Body, Place);
EndFunction // ProcDecl()

Function FuncDecl(Object, Decls, Auto, Body, Place = Undefined)
	// Хранит информацию об инструкции объявления функции.
	// Директива и признак экспорта хранятся в поле-узле "Object",
	// который является объектом области видимости представляющим эту функцию.
	// Пример:
	// <pre>
	// &НаКлиенте
	// Функция Тест() Экспорт
	//     Перем П1;    // поле "Decls" хранит объявления переменных.
	//     П1 = 2;      // поле "Body" хранит операторы.
	//     П2 = П1 + 2; // Авто-переменные (П2) собираются в поле "Auto".
	// КонецФункции
	// </pre>
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Object," // structure (Func)
		"Decls,"  // array (one of #Declarations)
		"Auto,"   // array (VarLoc)
		"Body,"   // array (one of #Statements)
		"Place"   // undefined, structure (Place)
	, Nodes.FuncDecl, Object, Decls, Auto, Body, Place);
EndFunction // FuncDecl()

#EndRegion // Declarations

#Region Expressions

Function BasicLitExpr(Kind, Value, Place = Undefined)
	// Хранит информацию о литерале примитивного типа.
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Kind,"  // string (one of Tokens)
		"Value," // undefined, string, number, boolean, date, null
		"Place"  // undefined, structure (Place)
	, Nodes.BasicLitExpr, Kind, Value, Place);
EndFunction // BasicLitExpr()

Function SelectExpr(Kind, Value, Place = Undefined)
	// Хранит информацию о селекторе.
	// Селектор может быть обращением через точку, обращением по индексу или вызовом метода.
	// Примеры:
	// <pre>
	// // селекторы заключены в скобки <...>
	// Значение = Объект<.Поле>  // обращение через точку; поле "Kind" = SelectKinds.Ident;
	//                           // поле "Value" хранит имя поля
	// Значение = Объект<[Ключ]> // обращение по индексу; поле "Kind" = SelectKinds.Index;
	//                           // поле "Value" хранит индекс-выражение
	// Значение = Объект<()>     // вызов метода; поле "Kind" = SelectKinds.Call;
	//                           // поле "Value" хранит список аргументов-выражений
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Kind,"  // string (one of SelectKinds)
		"Value," // string, structure (one of #Expressions), array (undefined, one of #Expressions)
		"Place"  // undefined, structure (Place)
	, Nodes.SelectExpr, Kind, Value, Place);
EndFunction // SelectExpr()

Function DesigExpr(Object, Select, Call, Place = Undefined)
	// Хранит информацию об указателе (идентификатор + селекторы).
	// Пример:
	// <pre>
	// // указатель заключен в скобки <...>
	// // поле "Object" будет содержать объект переменной "Запрос";
	// // поле "Select" будет содержать пять селекторов;
	// // поле "Call" будет равно Ложь, т.к. последний селектор не является вызовом.
	// Возврат <Запрос.Выполнить().Выгрузить()[0]>;
	// </pre>
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Object," // structure (Unknown, Func, Proc, VarMod, VarLoc, Param)
		"Select," // array (SelectExpr)
		"Call,"   // boolean
		"Place"   // undefined, structure (Place)
	, Nodes.DesigExpr, Object, Select, Call, Place);
EndFunction // DesigExpr()

Function UnaryExpr(Operator, Operand, Place = Undefined)
	// Хранит унарное выражение.
	// Пример:
	// <pre>
	// // унарные выражения заключены в скобки <...>
	// // поле "Operator" равно либо Tokens.Add, либо Tokens.Sub
	// // поле "Operand" хранит операнд-выражение
	// Значение = <-Сумма> * 2;
	// Значение = <+Сумма>;
	// Значение = <-(Сумма1 + Сумма2)> / 2;
	// </pre>
	Return New Structure( // @Node
		"Type,"     // string (one of Nodes)
		"Operator," // string (one of Tokens)
		"Operand,"  // structure (one of #Expressions)
		"Place"     // undefined, structure (Place)
	, Nodes.UnaryExpr, Operator, Operand, Place);
EndFunction // UnaryExpr()

Function BinaryExpr(Left, Operator, Right, Place = Undefined)
	// Хранит бинарное выражение.
	// Пример:
	// <pre>
	// // бинарные выражения заключены в скобки <...>
	// // поле "Operator" равно одному из допустимых операторов:
	// // - логических (кроме "Не")
	// // - реляционных
	// // - арифметических
	// // поля "Left" и "Right" содержат операнды-выражения
	// Если <Не Отмена И Продолжить> Тогда
	//     Значение = <Сумма1 + <Сумма2 * Коэффициент>>;
	// КонецЕсли;
	// </pre>
	Return New Structure( // @Node
		"Type,"     // string (one of Nodes)
		"Left,"     // structure (one of #Expressions)
		"Operator," // string (one of Tokens)
		"Right,"    // structure (one of #Expressions)
		"Place"     // undefined, structure (Place)
	, Nodes.BinaryExpr, Left, Operator, Right, Place);
EndFunction // BinaryExpr()

Function NewExpr(Name, Args, Place = Undefined)
	// Хранит выражение "Новый".
	// Пример:
	// <pre>
	// // выражения "Новый" заключены в скобки <...>
	// // в этом варианте поле "Name" хранит имя типа "Массив",
	// // а поле "Args" хранит массив из одного выражения
	// Параметры = <Новый Массив(1)>;
	// Параметры[0] = 10;
	// // в этом варианте поле "Name" равно Неопределено,
	// // а поле "Args" хранит массив из двух выражений
	// Массив = <Новый (Тип("Массив"), Параметры)>;
	// </pre>
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Name," // undefined, string
		"Args," // array (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.NewExpr, Name, Args, Place);
EndFunction // NewExpr()

Function TernaryExpr(Cond, ThenPart, ElsePart, Select, Place = Undefined)
	// Хранит тернарное выражение "?(,,)".
	// Пример:
	// <pre>
	// Значение = ?(Ложь,   // поле "Cond"
	//     Неопределено,    // поле "Then"
	//     Новый Массив     // поле "Else"
	// ).Количество();      // поле "Select"
	// </pre>
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Cond,"   // structure (one of #Expressions)
		"Then,"   // structure (one of #Expressions)
		"Else,"   // structure (one of #Expressions)
		"Select," // array (SelectExpr)
		"Place"   // undefined, structure (Place)
	, Nodes.TernaryExpr, Cond, ThenPart, ElsePart, Select, Place);
EndFunction // TernaryExpr()

Function ParenExpr(Expr, Place = Undefined)
	// Хранит скобочное выражение.
	// Пример:
	// <pre>
	// // скобочное выражение заключено в скобки <...>
	// Сумма = <(Сумма1 + Сумма2)> * Количество;
	// </pre>
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.ParenExpr, Expr, Place);
EndFunction // ParenExpr()

Function NotExpr(Expr, Place = Undefined)
	// Хранит выражение, к которому применено логическое отрицание "Не".
	// Пример:
	// <pre>
	// // выражение-отрицание заключено в скобки <...>
	// НеРавны = <Не Сумма1 = Сумма2>;
	// </pre>
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.NotExpr, Expr, Place);
EndFunction // NotExpr()

Function StringExpr(ExprList, Place = Undefined)
	// Хранит строковое выражение.
	// Поле "List" хранит упорядоченный список частей строки.
	// Пример:
	// <pre>
	// Строка1 = "Часть1" "Часть2"; // эта строка состоит из двух частей типа Nodes.String
	// Строка2 =                    // эта строка состоит из пяти частей типа:
	// "Начало строки               // Nodes.StringBeg
	// | продолжение строки         // Nodes.StringMid
	// | еще продолжение строки     // Nodes.StringMid
	// | окончание строки"          // Nodes.StringEnd
	// "еще часть";                 // Nodes.String
	// </pre>
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"List," // array (BasicLitExpr)
		"Place" // undefined, structure (Place)
	, Nodes.StringExpr, ExprList, Place);
EndFunction // StringExpr()

#EndRegion // Expressions

#Region Statements

Function AssignStmt(Left, Right, Place = Undefined)
	// Хранит оператор присваивания.
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Left,"  // structure (DesigExpr)
		"Right," // structure (one of #Expressions)
		"Place"  // undefined, structure (Place)
	, Nodes.AssignStmt, Left, Right, Place);
EndFunction // AssignStmt()

Function ReturnStmt(Expr = Undefined, Place = Undefined)
	// Хранит оператор "Возврат".
	// Поле "Expr" равно Неопределено если это возврат из процедуры.
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // undefined, structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.ReturnStmt, Expr, Place);
EndFunction // ReturnStmt()

Function BreakStmt(Place = Undefined)
	// Хранит оператор "Прервать".
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Place" // undefined, structure (Place)
	, Nodes.BreakStmt, Place);
EndFunction // BreakStmt()

Function ContinueStmt(Place = Undefined)
	// Хранит оператор "Продолжить".
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Place" // undefined, structure (Place)
	, Nodes.ContinueStmt, Place);
EndFunction // ContinueStmt()

Function RaiseStmt(Expr = Undefined, Place = Undefined)
	// Хранит оператор "ВызватьИсключение".
	// Поле "Expr" равно Неопределено если это вариант оператора без выражения.
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // undefined, structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.RaiseStmt, Expr, Place);
EndFunction // RaiseStmt()

Function ExecuteStmt(Expr, Place = Undefined)
	// Хранит оператор "Выполнить".
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // structure (one of #Expressions)
		"Place" // undefined, structure (Place)
	, Nodes.ExecuteStmt, Expr, Place);
EndFunction // ExecuteStmt()

Function CallStmt(DesigExpr, Place = Undefined)
	// Хранит вызов процедуры или функции как процедуры.
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Desig," // structure (DesigExpr)
		"Place"  // undefined, structure (Place)
	, Nodes.CallStmt, DesigExpr, Place);
EndFunction // CallStmt()

Function IfStmt(Cond, ThenPart, ElsIfPart = Undefined, ElsePart = Undefined, Place = Undefined)
	// Хранит оператор "Если".
	// Пример:
	// <pre>
	// Если Сумма > 0 Тогда // поле "Cond" хранит условие (выражение)
	//     // поле "Then" хранит операторы в этом блоке
	// ИначеЕсли Сумма = 0 Тогда
	//     // поле-массив "ElsIf" хранит последовательность блоков ИначеЕсли
	// Иначе
	//     // поле "Else" хранит операторы в этом блоке
	// КонецЕсли
	// </pre>
	// Поля "ElsIf" и "Else" равны Неопределено если
	// соответствующие блоки отсутствуют в исходном коде.
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Cond,"  // structure (one of #Expressions)
		"Then,"  // array (one of #Statements)
		"ElsIf," // undefined, array (ElsIfStmt)
		"Else,"  // undefined, array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.IfStmt, Cond, ThenPart, ElsIfPart, ElsePart, Place);
EndFunction // IfStmt()

Function ElsIfStmt(Cond, ThenPart, Place = Undefined)
	// Хранит блок "ИначеЕсли" оператора "Если".
	// Пример:
	// <pre>
	// ...
	// ИначеЕсли Сумма < 0 Тогда // поле "Cond" хранит условие (выражение)
	//     // поле "Then" хранит операторы в этом блоке
	// ...
	// </pre>
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Cond," // structure (one of #Expressions)
		"Then," // array (one of #Statements)
		"Place" // undefined, structure (Place)
	, Nodes.ElsIfStmt, Cond, ThenPart, Place);
EndFunction // ElsIfStmt()

Function WhileStmt(Cond, Statements, Place = Undefined)
	// Хранит оператор цикла "Пока".
	// Пример:
	// <pre>
	// Пока Индекс > 0 Цикл // поле "Cond" хранит условие (выражение)
	//     // поле "Body" хранит операторы в этом блоке
	// КонецЦикла
	// </pre>
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Cond," // structure (one of #Expressions)
		"Body," // array (one of #Statements)
		"Place" // undefined, structure (Place)
	, Nodes.WhileStmt, Cond, Statements, Place);
EndFunction // WhileStmt()

Function ForStmt(DesigExpr, From, Until, Statements, Place = Undefined)
	// Хранит оператор цикла "Для".
	// Пример:
	// <pre>
	// Для Индекс = 0      // поля "Desig" и "From" хранят переменную и выражение инициализации.
	//   По Длина - 1 Цикл // поле "To" хранит выражение границы
	//     // поле "Body" хранит операторы в этом блоке
	// КонецЦикла
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Desig," // structure (DesigExpr)
		"From,"  // structure (one of #Expressions)
		"To,"    // structure (one of #Expressions)
		"Body,"  // array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.ForStmt, DesigExpr, From, Until, Statements, Place);
EndFunction // ForStmt()

Function ForEachStmt(DesigExpr, Collection, Statements, Place = Undefined)
	// Хранит оператор цикла "Для Каждого".
	// Пример:
	// <pre>
	// Для Каждого Элемент // поле "Desig" хранит переменную.
	//   Из Список Цикл    // поле "In" хранит выражение коллекции.
	//     // поле "Body" хранит операторы в этом блоке
	// КонецЦикла
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Desig," // structure (DesigExpr)
		"In,"    // structure (one of #Expressions)
		"Body,"  // array (one of #Statements)
		"Place"  // undefined, structure (Place)
	, Nodes.ForEachStmt, DesigExpr, Collection, Statements, Place);
EndFunction // ForEachStmt()

Function TryStmt(TryPart, ExceptPart, Place = Undefined)
	// Хранит оператор "Попытка"
	// Пример:
	// <pre>
	// Попытка
	//     // поле "Try" хранит операторы в этом блоке.
	// Исключение
	//     // поле "Except" хранит операторы в этом блоке
	// КонецПопытки
	// </pre>
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Try,"    // array (one of #Statements)
		"Except," // array (one of #Statements)
		"Place"   // undefined, structure (Place)
	, Nodes.TryStmt, TryPart, ExceptPart, Place);
EndFunction // TryStmt()

Function GotoStmt(Label, Place = Undefined)
	// Хранит оператор "Перейти"
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Label," // string
		"Place"  // undefined, structure (Place)
	, Nodes.GotoStmt, Label, Place);
EndFunction // GotoStmt()

Function LabelStmt(Label, Place = Undefined)
	// Хранит оператор метки.
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Label," // string
		"Place"  // undefined, structure (Place)
	, Nodes.LabelStmt, Label, Place);
EndFunction // LabelStmt()

#EndRegion // Statements

#Region PrepInst

Function PrepIfInst(Cond, Place = Undefined)
	// Хранит информацию об инструкции препроцессора #Если,
	// Пример:
	// <pre>
	// ...
	// #Если Сервер Тогда // поле "Cond" хранит условие (выражение)
	// ...
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Cond,"  // structure (one of #PrepExpr)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepIfInst, Cond, Place);
EndFunction // PrepIfInst()

Function PrepElsIfInst(Cond, Place = Undefined)
	// Хранит информацию об инструкции препроцессора #ИначеЕсли
	// Пример:
	// <pre>
	// ...
	// #ИначеЕсли Клиент Тогда // поле "Cond" хранит условие (выражение)
	// ...
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Cond,"  // structure (one of #PrepExpr)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepElsIfInst, Cond, Place);
EndFunction // PrepElsIfInst()

Function PrepElseInst(Place = Undefined)
	// Хранит информацию об инструкции препроцессора #Иначе
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepElseInst, Place);
EndFunction // PrepElseInst()

Function PrepEndIfInst(Place = Undefined)
	// Хранит информацию об инструкции препроцессора #КонецЕсли
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepEndIfInst, Place);
EndFunction // PrepEndIfInst()

Function PrepRegionInst(Name, Place = Undefined)
	// Хранит информацию об инструкции препроцессора #Обрасть,
	// Пример:
	// <pre>
	// ...
	// #Область Интерфейс   // поле "Name" хранит имя области
	// ...
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Name,"  // string
		"Place"  // undefined, structure (Place)
	, Nodes.PrepRegionInst, Name, Place);
EndFunction // PrepRegionInst()

Function PrepEndRegionInst(Place = Undefined)
	// Хранит информацию об инструкции препроцессора #КонецОбласти,
	// Пример:
	// <pre>
	// ...
	// #КонецОбласти
	// ...
	// </pre>
	Return New Structure( // @Node
		"Type,"  // string (one of Nodes)
		"Place"  // undefined, structure (Place)
	, Nodes.PrepEndRegionInst, Place);
EndFunction // PrepEndRegionInst()

Function PrepUseInst(Path, Place = Undefined)
	// Хранит информацию об инструкции препроцессора #Использовать,
	// Это нестандартная инструкция из OneScript
	// Пример:
	// <pre>
	// #Использовать 1commands // поле "Path" хранит имя библиотеки или путь в кавычках
	// </pre>
	Return New Structure( // @Node @OneScript
	  "Type," // string (one of Nodes)
	  "Path," // string
	  "Place" // undefined, structure (Place)
	, Nodes.PrepUseInst, Path, Place);
EndFunction // PrepUseInst()

#EndRegion // PrepInst

#Region PrepExpr

Function PrepBinaryExpr(Left, Operator, Right, Place = Undefined)
	// Хранит бинарное выражение препроцессора.
	// Пример:
	// <pre>
	// // бинарные выражения заключены в скобки <...>
	// // поле "Operator" равно либо Tokens.Or либо Tokens.And:
	// // поля "Left" и "Right" содержат операнды-выражения препроцессора
	// #Если <Сервер Или ВнешнееСоединение> Тогда
	// ...
	// </pre>
	Return New Structure( // @Node
		"Type,"     // string (one of Nodes)
		"Left,"     // structure (one of #PrepExpr)
		"Operator," // string (one of Tokens)
		"Right,"    // structure (one of #PrepExpr)
		"Place"     // undefined, structure (Place)
	, Nodes.PrepBinaryExpr, Left, Operator, Right, Place);
EndFunction // PrepBinaryExpr()

Function PrepNotExpr(Expr, Place = Undefined)
	// Хранит выражение препроцессора, к которому применено логическое отрицание "Не".
	// Пример:
	// <pre>
	// // выражение-отрицание заключено в скобки <...>
	// #Если <Не ВебКлиент> Тогда
	// ...
	// </pre>
	Return New Structure( // @Node
		"Type," // string (one of Nodes)
		"Expr," // structure (one of #PrepExpr)
		"Place" // undefined, structure (Place)
	, Nodes.PrepNotExpr, Expr, Place);
EndFunction // PrepNotExpr()

Function PrepSymExpr(Symbol, Exist, Place = Undefined)
	// Узел хранит информацию о символе препроцессора.
	// Поле Exist = True если такой символ существует.
	// Пример:
	// <pre>
	// // символ заключен в скобки <...>
	// #Если <Сервер> Тогда
	// </pre>
	Return New Structure( // @Node
		"Type,"   // string (one of Nodes)
		"Symbol," // string (one of PrepSymbols)
		"Exist,"  // boolean
		"Place"   // undefined, structure (Place)
	, Nodes.PrepSymExpr, Symbol, Exist, Place);
EndFunction // PrepSymExpr()

#EndRegion // PrepExpr

#EndRegion // AbstractSyntaxTree

#Region Parser

Function Parser(Source) Export

	Parser_Source = Source;
	Parser_Pos = 0;
	Parser_Line = 1;
	Parser_EndLine = 1;
	Parser_BegPos = 0;
	Parser_EndPos = 0;
	Parser_Methods = New Structure;
	Parser_Unknown = New Structure;
	Parser_IsFunc = False;
	Parser_AllowVar = True;
	Parser_Interface = New Array;
	Parser_Comments = New Map;

	Parser_Len = StrLen(Source);
	Parser_Lit = "";
	
	Parser_Char = Undefined;
	
	OpenScope();

	Return Undefined;

EndFunction // Parser()

Function Next() Export
	Var Beg, Prev, Comment;

	Parser_EndPos = Parser_Pos; Parser_EndLine = Parser_Line;

	If Right(Parser_Lit, 1) = Chars.LF Then Parser_Line = Parser_Line + 1 EndIf;

	While True Do

		Comment = False;

		// skip space
		While IsBlankString(Parser_Char) And Parser_Char <> "" Do
			If Parser_Char = Chars.LF Then Parser_Line = Parser_Line + 1 EndIf;
			Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
		EndDo;

		Parser_BegPos = Parser_Pos;

		Parser_Tok = TokenMap[Parser_Char];
		If Parser_Tok = Alpha Then

			// scan ident
			Beg = Parser_Pos; Parser_Pos = Parser_Pos + 1;
			While AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] <> Undefined Do Parser_Pos = Parser_Pos + 1 EndDo;
			Parser_Char = Mid(Parser_Source, Parser_Pos, 1); Parser_Lit = Mid(Parser_Source, Beg, Parser_Pos - Beg);

			// lookup
			If Not Keywords.Property(Parser_Lit, Parser_Tok) Then Parser_Tok = Tokens.Ident EndIf;

		ElsIf Parser_Tok = Tokens.String Then

			Beg = Parser_Pos;
			Parser_Char = """"; // cheat code
			While Parser_Char = """" Do
				Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
				While Parser_Char <> """" And Parser_Char <> Chars.LF And Parser_Char <> "" Do Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1) EndDo;
				If Parser_Char <> "" Then Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1) EndIf;
			EndDo;
			Parser_Lit = Mid(Parser_Source, Beg, Parser_Pos - Beg);

			Parser_Tok = StringToken(Parser_Lit);

		ElsIf Parser_Tok = Digit Then

			Beg = Parser_Pos; Parser_Pos = Parser_Pos + 1;
			While AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] = Digit Do Parser_Pos = Parser_Pos + 1 EndDo;
			Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
			If Parser_Char = "." Then
				Parser_Pos = Parser_Pos + 1;
				While AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] = Digit Do Parser_Pos = Parser_Pos + 1 EndDo;
				Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
			EndIf;
			Parser_Lit = Mid(Parser_Source, Beg, Parser_Pos - Beg);

			Parser_Tok = Tokens.Number;

		ElsIf Parser_Tok = Tokens.DateTime Then

			Parser_Pos = Parser_Pos + 1; Beg = Parser_Pos;
			Parser_Pos = StrFind(Parser_Source, "'",, Parser_Pos);
			If Parser_Pos = 0 Then
				Parser_Char = ""
			Else
				Parser_Lit = Mid(Parser_Source, Beg, Parser_Pos - Beg);
				Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
			EndIf;

		ElsIf Parser_Tok = Undefined Then

			Prev = Parser_Char;
			Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);

			If Prev = "/" Then

				If Parser_Char = "/" Then
					// scan comment
					Beg = Parser_Pos + 1; Parser_Pos = StrFind(Parser_Source, Chars.LF,, Beg);
					Parser_Comments[Parser_Line] = Mid(Parser_Source, Beg, Parser_Pos - Beg);
					If Parser_Pos = 0 Then Parser_Char = "" Else Parser_Char = Mid(Parser_Source, Parser_Pos, 1) EndIf;
					Comment = True;
				Else
					Parser_Tok = Tokens.Div;
				EndIf;

			ElsIf Prev = "<" Then

				If Parser_Char = ">" Then
					Parser_Tok = Tokens.Neq;
					Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
				ElsIf Parser_Char = "=" Then
					Parser_Tok = Tokens.Leq;
					Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
				Else
					Parser_Tok = Tokens.Lss;
				EndIf;

			ElsIf Prev = ">" Then

				If Parser_Char = "=" Then
					Parser_Tok = Tokens.Geq;
					Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
				Else
					Parser_Tok = Tokens.Gtr;
				EndIf;

			ElsIf Prev = "&" Then

				If AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] <> Alpha Then
					Error("Expected directive", Parser_Pos, True);
				EndIf;

				// scan ident
				Beg = Parser_Pos; Parser_Pos = Parser_Pos + 1;
				While AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] <> Undefined Do Parser_Pos = Parser_Pos + 1 EndDo;
				Parser_Char = Mid(Parser_Source, Parser_Pos, 1); Parser_Lit = Mid(Parser_Source, Beg, Parser_Pos - Beg);

				If Not Directives.Property(Parser_Lit) Then
					Error(StrTemplate("Unknown directive: '%1'", Parser_Lit));
				EndIf;

				Parser_Tok = Tokens.Directive;

			ElsIf Prev = "#" Then

				// skip space
				While IsBlankString(Parser_Char) And Parser_Char <> "" Do
					If Parser_Char = Chars.LF Then Parser_Line = Parser_Line + 1 EndIf;
					Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
				EndDo;

				If AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] <> Alpha Then
					Error("Expected preprocessor instruction", Parser_Pos, True);
				EndIf;

				// scan ident
				Beg = Parser_Pos; Parser_Pos = Parser_Pos + 1;
				While AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] <> Undefined Do Parser_Pos = Parser_Pos + 1 EndDo;
				Parser_Char = Mid(Parser_Source, Parser_Pos, 1); Parser_Lit = Mid(Parser_Source, Beg, Parser_Pos - Beg);

				// match token
				If PrepInstructions.Property(Parser_Lit, Parser_Tok) Then Parser_Tok = "_" + Parser_Tok;
				Else Error(StrTemplate("Unknown preprocessor instruction: '%1'", Parser_Lit));
				EndIf;

			ElsIf Prev = "~" Then

				// skip space
				While IsBlankString(Parser_Char) And Parser_Char <> "" Do
					If Parser_Char = Chars.LF Then Parser_Line = Parser_Line + 1 EndIf;
					Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);
				EndDo;

				If AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] = Undefined Then
					Parser_Lit = "";
				Else
					// scan ident
					Beg = Parser_Pos; Parser_Pos = Parser_Pos + 1;
					While AlphaDigitMap[Mid(Parser_Source, Parser_Pos, 1)] <> Undefined Do Parser_Pos = Parser_Pos + 1 EndDo;
					Parser_Char = Mid(Parser_Source, Parser_Pos, 1); Parser_Lit = Mid(Parser_Source, Beg, Parser_Pos - Beg);
				EndIf;

				Parser_Tok = Tokens.Label;

			Else

				Raise "Unknown char!";

			EndIf;

		Else

			Parser_Pos = Parser_Pos + 1; Parser_Char = Mid(Parser_Source, Parser_Pos, 1);

		EndIf;

		If Not Comment Then
			Break;
		EndIf;

	EndDo;

	If Parser_Tok = Tokens.Number Then
		Parser_Val = Number(Parser_Lit);
	ElsIf Parser_Tok = Tokens.True Then
		Parser_Val = True;
	ElsIf Parser_Tok = Tokens.False Then
		Parser_Val = False;
	ElsIf Parser_Tok = Tokens.DateTime Then
		Parser_Val = AsDate(Parser_Lit);
	ElsIf Left(Parser_Tok, 6) = Tokens.String Then
		Parser_Val = Mid(Parser_Lit, 2, StrLen(Parser_Lit) - 2);
	ElsIf Parser_Tok = Tokens.Null Then
		Parser_Val = Null;
	Else
		Parser_Val = Undefined;
	EndIf;

	Return Parser_Tok;

EndFunction // Next()

Function FindObject(Name)
	Var Scope, Object;
	Scope = Parser_Scope;
	Scope.Objects.Property(Name, Object);
	While Object = Undefined And Scope.Outer <> Undefined Do
		Scope = Scope.Outer;
		Scope.Objects.Property(Name, Object);
	EndDo;
	Return Object;
EndFunction // FindObject()

Function OpenScope()
	Var Scope;
	Scope = Scope(Parser_Scope);
	Parser_Scope = Scope;
	Parser_Vars = Scope.Objects;
	Return Scope;
EndFunction // OpenScope()

Function CloseScope()
	Var Scope;
	Scope = Parser_Scope.Outer;
	Parser_Scope = Scope;
	Parser_Vars = Scope.Objects;
	Return Scope;
EndFunction // CloseScope()

Function ParseModule() Export
	Var Decls, Auto, VarObj, Item, Statements, Module;
	Next();
	Decls = ParseModDecls();
	Statements = ParseStatements();
	Auto = New Array;
	For Each VarObj In Parser_Scope.Auto Do
		Auto.Add(VarObj);
	EndDo;
	Module = Module(Decls, Auto, Statements, Parser_Interface, Parser_Comments);
	If Verbose Then
		For Each Item In Parser_Unknown Do
			Message(StrTemplate("Undeclared method `%1`", Item.Key));
		EndDo;
	EndIf;
	Expect(Tokens.Eof);
	Parser_Unknown = Undefined;
	Parser_Methods = Undefined;
	Parser_Directive = Undefined;
	Parser_Interface = Undefined;
	Parser_Comments = Undefined;
	Parser_Scope = Undefined;
	Parser_Vars = Undefined;
	Parser_Source = Undefined;
	Return Module;
EndFunction // ParseModule()

#Region ParseExpr

Function ParseExpression()
	Var Expr, Operator, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Expr = ParseAndExpr();
	While Parser_Tok = Tokens.Or Do
		Operator = Parser_Tok;
		Next();
		Expr = BinaryExpr(Expr, Operator, ParseAndExpr(), Place(Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseExpression()

Function ParseAndExpr()
	Var Expr, Operator, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Expr = ParseNotExpr();
	While Parser_Tok = Tokens.And Do
		Operator = Parser_Tok;
		Next();
		Expr = BinaryExpr(Expr, Operator, ParseNotExpr(), Place(Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseAndExpr()

Function ParseNotExpr()
	Var Expr, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	If Parser_Tok = Tokens.Not Then
		Next();
		Expr = NotExpr(ParseRelExpr(), Place(Pos, Line));
	Else
		Expr = ParseRelExpr();
	EndIf;
	Return Expr;
EndFunction // ParseNotExpr()

Function ParseRelExpr()
	Var Expr, Operator, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Expr = ParseAddExpr();
	While RelOperators.Find(Parser_Tok) <> Undefined Do
		Operator = Parser_Tok;
		Next();
		Expr = BinaryExpr(Expr, Operator, ParseAddExpr(), Place(Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseRelExpr()

Function ParseAddExpr()
	Var Expr, Operator, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Expr = ParseMulExpr();
	While AddOperators.Find(Parser_Tok) <> Undefined Do
		Operator = Parser_Tok;
		Next();
		Expr = BinaryExpr(Expr, Operator, ParseMulExpr(), Place(Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseAddExpr()

Function ParseMulExpr()
	Var Expr, Operator, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Expr = ParseUnaryExpr();
	While MulOperators.Find(Parser_Tok) <> Undefined Do
		Operator = Parser_Tok;
		Next();
		Expr = BinaryExpr(Expr, Operator, ParseUnaryExpr(), Place(Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParseMulExpr()

Function ParseUnaryExpr()
	Var Operator, Expr, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Operator = Parser_Tok;
	If AddOperators.Find(Parser_Tok) <> Undefined Then
		Next();
		Expr = UnaryExpr(Operator, ParseOperand(), Place(Pos, Line));
	ElsIf Parser_Tok = Tokens.Eof Then
		Expr = Undefined;
	Else
		Expr = ParseOperand();
	EndIf;
	Return Expr;
EndFunction // ParseUnaryExpr()

Function ParseOperand()
	Var Tok, Operand;
	Tok = Parser_Tok;
	If Tok = Tokens.String Or Tok = Tokens.StringBeg Then
		Operand = ParseStringExpr();
	ElsIf BasicLitNoString.Find(Tok) <> Undefined Then
		Operand = BasicLitExpr(Tok, Parser_Val, Place());
		Next();
	ElsIf Tok = Tokens.Ident Then
		Operand = ParseDesigExpr();
	ElsIf Tok = Tokens.Lparen Then
		Operand = ParseParenExpr();
	ElsIf Tok = Tokens.New Then
		Operand = ParseNewExpr();
	ElsIf Tok = Tokens.Ternary Then
		Operand = ParseTernaryExpr();
	Else
		Error("Expected operand",, True);
	EndIf;
	Return Operand;
EndFunction // ParseOperand()

Function ParseStringExpr()
	Var Tok, ExprList, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Tok = Parser_Tok;
	ExprList = New Array;
	While True Do
		If Tok = Tokens.String Then
			ExprList.Add(BasicLitExpr(Tok, Parser_Val, Place()));
			Tok = Next();
			While Tok = Tokens.String Do
				ExprList.Add(BasicLitExpr(Tok, Parser_Val, Place()));
				Tok = Next();
			EndDo;
		ElsIf Tok = Tokens.StringBeg Then
			ExprList.Add(BasicLitExpr(Tok, Parser_Val, Place()));
			Tok = Next();
			While Tok = Tokens.StringMid Do
				ExprList.Add(BasicLitExpr(Tok, Parser_Val, Place()));
				Tok = Next();
			EndDo;
			If Tok <> Tokens.StringEnd Then
				Error("Expected """,, True);
			EndIf;
			ExprList.Add(BasicLitExpr(Tok, Parser_Val, Place()));
			Tok = Next();
		Else
			Break;
		EndIf;
	EndDo;
	Return StringExpr(ExprList, Place(Pos, Line));
EndFunction // ParseStringExpr()

Function ParseNewExpr()
	Var Tok, Name, Args, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Tok = Next();
	If Tok = Tokens.Ident Then
		Name = Parser_Lit;
		Args = EmptyArray;
		Tok = Next();
	EndIf;
	If Tok = Tokens.Lparen Then
		Tok = Next();
		If Tok <> Tokens.Rparen Then
			Args = ParseArguments();
			Expect(Tokens.Rparen);
		EndIf;
		Next();
	EndIf;
	If Name = Undefined And Args = Undefined Then
		Error("Expected constructor", Parser_EndPos, True);
	EndIf;
	Return NewExpr(Name, Args, Place(Pos, Line));
EndFunction // ParseNewExpr()

Function ParseDesigExpr(Val AllowNewVar = False, NewVar = Undefined)
	Var Name, SelectExpr, Object, List, Kind, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Name = Parser_Lit;
	Next();
	SelectExpr = ParseSelectExpr();
	If SelectExpr = Undefined Then
		Object = FindObject(Name);
		List = EmptyArray;
	Else
		AllowNewVar = False;
		Kind = SelectExpr.Kind;
		If Kind = "Call" Then
			If Not Parser_Methods.Property(Name, Object) Then
				If Not Parser_Unknown.Property(Name, Object) Then
					Object = Unknown(Name);
					Parser_Unknown.Insert(Name, Object);
				EndIf;
			EndIf;
		Else
			Object = FindObject(Name);
		EndIf;
		List = New Array;
		List.Add(SelectExpr);
		SelectExpr = ParseSelectExpr();
		While SelectExpr <> Undefined Do
			Kind = SelectExpr.Kind;
			List.Add(SelectExpr);
			SelectExpr = ParseSelectExpr();
		EndDo;
	EndIf;
	If Object = Undefined Then
		If AllowNewVar Then
			Object = VarLoc(Name, True);
			NewVar = Object;
		Else
			Object = Unknown(Name);
			If Verbose Then
				Error(StrTemplate("Undeclared identifier `%1`", Name), Pos);
			EndIf;
		EndIf;
	EndIf;
	Return DesigExpr(Object, List, Kind = SelectKinds.Call, Place(Pos, Line));
EndFunction // ParseDesigExpr()

Function ParseSelectExpr()
	Var Tok, Value, SelectExpr, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Tok = Parser_Tok;
	If Tok = Tokens.Period Then
		Next();
		If Not Keywords.Property(Parser_Lit) Then
			Expect(Tokens.Ident);
		EndIf;
		Value = Parser_Lit;
		Next();
		SelectExpr = SelectExpr(SelectKinds.Ident, Value, Place(Pos, Line));
	ElsIf Tok = Tokens.Lbrack Then
		Tok = Next();
		If Tok = Tokens.Rbrack Then
			Error("Expected expression", Pos, True);
		EndIf;
		Value = ParseExpression();
		Expect(Tokens.Rbrack);
		Next();
		SelectExpr = SelectExpr(SelectKinds.Index, Value, Place(Pos, Line));
	ElsIf Tok = Tokens.Lparen Then
		Tok = Next();
		If Tok = Tokens.Rparen Then
			Value = EmptyArray;
		Else
			Value = ParseArguments();
		EndIf;
		Expect(Tokens.Rparen);
		Next();
		SelectExpr = SelectExpr(SelectKinds.Call, Value, Place(Pos, Line));
	EndIf;
	Return SelectExpr;
EndFunction // ParseSelectExpr()

Function ParseArguments()
	Var ExprList;
	ExprList = New Array;
	While True Do
		If InitOfExpression.Find(Parser_Tok) <> Undefined Then
			ExprList.Add(ParseExpression());
		Else
			ExprList.Add(Undefined);
		EndIf;
		If Parser_Tok = Tokens.Comma Then
			Next();
		Else
			Break;
		EndIf;
	EndDo;
	Return ExprList;
EndFunction // ParseArguments()

Function ParseTernaryExpr()
	Var Cond, ThenPart, ElsePart, SelectList, SelectExpr, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Next();
	Expect(Tokens.Lparen);
	Next();
	Cond = ParseExpression();
	Expect(Tokens.Comma);
	Next();
	ThenPart = ParseExpression();
	Expect(Tokens.Comma);
	Next();
	ElsePart = ParseExpression();
	Expect(Tokens.Rparen);
	If Next() = Tokens.Period Then
		SelectList = New Array;
		SelectExpr = ParseSelectExpr();
		While SelectExpr <> Undefined Do
			SelectList.Add(SelectExpr);
			SelectExpr = ParseSelectExpr();
		EndDo;
	Else
		SelectList = EmptyArray;
	EndIf;
	Return TernaryExpr(Cond, ThenPart, ElsePart, SelectList, Place(Pos, Line));
EndFunction // ParseTernaryExpr()

Function ParseParenExpr()
	Var Expr, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Next();
	Expr = ParseExpression();
	Expect(Tokens.Rparen);
	Next();
	Return ParenExpr(Expr, Place(Pos, Line));
EndFunction // ParseParenExpr()

#EndRegion // ParseExpr

#Region ParseDecl

Function ParseModDecls()
	Var Tok, Decls, Inst;
	Tok = Parser_Tok;
	Decls = New Array;
	While Tok = Tokens.Directive Do
		Parser_Directive = Directives[Parser_Lit];
		Tok = Next();
	EndDo;
	While True Do
		Pos = Parser_BegPos;
		Line = Parser_Line;
		If Tok = Tokens.Var And Parser_AllowVar Then
			Decls.Add(ParseVarModDecl());
		ElsIf Tok = Tokens.Function Then
			Decls.Add(ParseFuncDecl());
			Parser_AllowVar = False;
		ElsIf Tok = Tokens.Procedure Then
			Decls.Add(ParseProcDecl());
			Parser_AllowVar = False;
		ElsIf Tok = Tokens._Region Then
			Inst = ParsePrepRegionInst();
			Next();
			Inst.Place = Place(Pos, Line);
			Decls.Add(Inst);
		ElsIf Tok = Tokens._EndRegion Then
			Next();
			Decls.Add(PrepEndRegionInst(Place(Pos, Line)));
		ElsIf Tok = Tokens._If Then
			Inst = ParsePrepIfInst();
			Next();
			Inst.Place = Place(Pos, Line);
			Decls.Add(Inst);
		ElsIf Tok = Tokens._ElsIf Then
			Inst = ParsePrepElsIfInst();
			Next();
			Inst.Place = Place(Pos, Line);
			Decls.Add(Inst);
		ElsIf Tok = Tokens._Else Then
			Next();
			Decls.Add(PrepElseInst(Place(Pos, Line)));
		ElsIf Tok = Tokens._EndIf Then
			Next();
			Decls.Add(PrepEndIfInst(Place(Pos, Line)));
		ElsIf Tok = Tokens._Use Then
			Decls.Add(ParsePrepUseInst());
		Else
			Break;
		EndIf;
		Tok = Parser_Tok;
		Parser_Directive = Undefined;
		While Tok = Tokens.Directive Do
			Parser_Directive = Directives[Parser_Lit];
			Tok = Next();
		EndDo;
	EndDo;
	Return Decls;
EndFunction // ParseModDecls()

Function ParseVarModDecl()
	Var VarList, Decl, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Next();
	VarList = New Array;
	VarList.Add(ParseVarMod());
	While Parser_Tok = Tokens.Comma Do
		Next();
		VarList.Add(ParseVarMod());
	EndDo;
	Decl = VarModDecl(Parser_Directive, VarList, Place(Pos, Line));
	Expect(Tokens.Semicolon);
	Next();
	While Parser_Tok = Tokens.Semicolon Do
		Next();
	EndDo;
	Return Decl;
EndFunction // ParseVarModDecl()

Function ParseVarMod()
	Var Name, Object, Exported, Pos;
	Pos = Parser_BegPos;
	Expect(Tokens.Ident);
	Name = Parser_Lit;
	If Next() = Tokens.Export Then
		Exported = True;
		Next();
	Else
		Exported = False;
	EndIf;
	Object = VarMod(Name, Parser_Directive, Exported);
	If Exported Then
		Parser_Interface.Add(Object);
	EndIf;
	If Parser_Vars.Property(Name) Then
		Error("Identifier already declared", Pos, True);
	EndIf;
	Parser_Vars.Insert(Name, Object);
	Return Object;
EndFunction // ParseVarMod()

Function ParseVarDecls()
	Var Tok, Decls;
	Decls = New Array;
	Tok = Parser_Tok;
	While Tok = Tokens.Var Do
		Decls.Add(ParseVarLocDecl());
		Expect(Tokens.Semicolon);
		Tok = Next();
	EndDo;
	Return Decls;
EndFunction // ParseVarDecls()

Function ParseVarLocDecl()
	Var VarList, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Next();
	VarList = New Array;
	VarList.Add(ParseVarLoc());
	While Parser_Tok = Tokens.Comma Do
		Next();
		VarList.Add(ParseVarLoc());
	EndDo;
	Return VarLocDecl(VarList, Place(Pos, Line));
EndFunction // ParseVarLocDecl()

Function ParseVarLoc()
	Var Name, Object, Pos;
	Pos = Parser_BegPos;
	Expect(Tokens.Ident);
	Name = Parser_Lit;
	Object = VarLoc(Name);
	If Parser_Vars.Property(Name) Then
		Error("Identifier already declared", Pos, True);
	EndIf;
	Parser_Vars.Insert(Name, Object);
	Next();
	Return Object;
EndFunction // ParseVarLoc()

Function ParseFuncDecl()
	Var Object, Name, Decls, ParamList, Exported, Statements, Auto, VarObj, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Exported = False;
	Next();
	Expect(Tokens.Ident);
	Name = Parser_Lit;
	Next();
	OpenScope();
	ParamList = ParseParamList();
	If Parser_Tok = Tokens.Export Then
		Exported = True;
		Next();
	EndIf;
	If Parser_Unknown.Property(Name, Object) Then
		Object.Type = Nodes.Func;
		Object.Insert("Directive", Parser_Directive);
		Object.Insert("Params", ParamList);
		Object.Insert("Export", Exported);
		Parser_Unknown.Delete(Name);
	Else
		Object = Func(Name, Parser_Directive, ParamList, Exported);
	EndIf;
	If Parser_Methods.Property(Name) Then
		Error("Method already declared", Pos, True);
	EndIf;
	Parser_Methods.Insert(Name, Object);
	If Exported Then
		Parser_Interface.Add(Object);
	EndIf;
	Decls = ParseVarDecls();
	Parser_IsFunc = True;
	Statements = ParseStatements();
	Parser_IsFunc = False;
	Expect(Tokens.EndFunction);
	Auto = New Array;
	For Each VarObj In Parser_Scope.Auto Do
		Auto.Add(VarObj);
	EndDo;
	CloseScope();
	Next();
	Return FuncDecl(Object, Decls, Auto, Statements, Place(Pos, Line));
EndFunction // ParseFuncDecl()

Function ParseProcDecl()
	Var Object, Name, Decls, ParamList, Exported, Auto, VarObj, Statements, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Exported = False;
	Next();
	Expect(Tokens.Ident);
	Name = Parser_Lit;
	Next();
	OpenScope();
	ParamList = ParseParamList();
	If Parser_Tok = Tokens.Export Then
		Exported = True;
		Next();
	EndIf;
	If Parser_Unknown.Property(Name, Object) Then
		Object.Type = Nodes.Proc;
		Object.Insert("Directive", Parser_Directive);
		Object.Insert("Params", ParamList);
		Object.Insert("Export", Exported);
		Parser_Unknown.Delete(Name);
	Else
		Object = Proc(Name, Parser_Directive, ParamList, Exported);
	EndIf;
	If Parser_Methods.Property(Name) Then
		Error("Method already declared", Pos, True);
	EndIf;
	Parser_Methods.Insert(Name, Object);
	If Exported Then
		Parser_Interface.Add(Object);
	EndIf;
	Decls = ParseVarDecls();
	Statements = ParseStatements();
	Expect(Tokens.EndProcedure);
	Auto = New Array;
	For Each VarObj In Parser_Scope.Auto Do
		Auto.Add(VarObj);
	EndDo;
	CloseScope();
	Next();
	Return ProcDecl(Object, Decls, Auto, Statements, Place(Pos, Line));
EndFunction // ParseProcDecl()

Function ParseParamList()
	Var ParamList;
	Expect(Tokens.Lparen);
	Next();
	If Parser_Tok = Tokens.Rparen Then
		ParamList = EmptyArray;
	Else
		ParamList = New Array;
		ParamList.Add(ParseParameter());
		While Parser_Tok = Tokens.Comma Do
			Next();
			ParamList.Add(ParseParameter());
		EndDo;
	EndIf;
	Expect(Tokens.Rparen);
	Next();
	Return ParamList;
EndFunction // ParseParamList()

Function ParseParameter()
	Var Name, Object, ByVal, Pos;
	Pos = Parser_BegPos;
	If Parser_Tok = Tokens.Val Then
		ByVal = True;
		Next();
	Else
		ByVal = False;
	EndIf;
	Expect(Tokens.Ident);
	Name = Parser_Lit;
	If Next() = Tokens.Eql Then
		Next();
		Object = Param(Name, ByVal, ParseUnaryExpr());
	Else
		Object = Param(Name, ByVal);
	EndIf;
	If Parser_Vars.Property(Name) Then
		Error("Identifier already declared", Pos, True);
	EndIf;
	Parser_Vars.Insert(Name, Object);
	Return Object;
EndFunction // ParseParameter()

#EndRegion // ParseDecl

#Region ParseStmt

Function ParseStatements()
	Var Statements, Stmt;
	Statements = New Array;
	Stmt = ParseStmt();
	If Stmt <> Undefined Then
		Statements.Add(Stmt);
	EndIf;
	While True Do
		If Parser_Tok = Tokens.Semicolon Then
			Next();
		ElsIf Left(Parser_Tok, 1) <> "_" Then
			Break;		
		EndIf; 
		Stmt = ParseStmt();
		If Stmt <> Undefined Then
			Statements.Add(Stmt);
		EndIf;
	EndDo;
	Return Statements;
EndFunction // ParseStatements()

Function ParseStmt()
	Var Tok, Stmt, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Tok = Parser_Tok;
	If Tok = Tokens.Ident Then
		Stmt = ParseAssignOrCallStmt();
	ElsIf Tok = Tokens.If Then
		Stmt = ParseIfStmt();
	ElsIf Tok = Tokens.Try Then
		Stmt = ParseTryStmt();
	ElsIf Tok = Tokens.While Then
		Stmt = ParseWhileStmt();
	ElsIf Tok = Tokens.For Then
		If Next() = Tokens.Each Then
			Stmt = ParseForEachStmt();
		Else
			Stmt = ParseForStmt();
		EndIf;
	ElsIf Tok = Tokens.Return Then
		Stmt = ParseReturnStmt();
	ElsIf Tok = Tokens.Break Then
		Next();
		Stmt = BreakStmt();
	ElsIf Tok = Tokens.Continue Then
		Next();
		Stmt = ContinueStmt();
	ElsIf Tok = Tokens.Raise Then
		Stmt = ParseRaiseStmt();
	ElsIf Tok = Tokens.Execute Then
		Stmt = ParseExecuteStmt();
	ElsIf Tok = Tokens.Goto Then
		Stmt = ParseGotoStmt();
	ElsIf Tok = Tokens.Label Then
		Stmt = LabelStmt(Parser_Lit);
		Next();
		Expect(Tokens.Colon);
		Parser_Tok = Tokens.Semicolon; // cheat code
	ElsIf Tok = Tokens._Region Then
		Stmt = ParsePrepRegionInst();
	ElsIf Tok = Tokens._EndRegion Then
		Stmt = PrepEndRegionInst();
		Parser_Tok = Tokens.Semicolon; // cheat code
	ElsIf Tok = Tokens._If Then
		Stmt = ParsePrepIfInst();
	ElsIf Tok = Tokens._ElsIf Then
		Stmt = ParsePrepElsIfInst();
	ElsIf Tok = Tokens._Else Then
		Stmt = PrepElseInst();
		Parser_Tok = Tokens.Semicolon; // cheat code
	ElsIf Tok = Tokens._EndIf Then
		Stmt = PrepEndIfInst();
		Parser_Tok = Tokens.Semicolon; // cheat code
	ElsIf Tok = Tokens.Semicolon Then
		// NOP
	EndIf;
	If Stmt <> Undefined Then
		Stmt.Place = Place(Pos, Line);
	EndIf;
	Return Stmt;
EndFunction // ParseStmt()

Function ParseRaiseStmt()
	Var Expr;
	If InitOfExpression.Find(Next()) <> Undefined Then
		Expr = ParseExpression();
	EndIf;
	Return RaiseStmt(Expr);
EndFunction // ParseRaiseStmt()

Function ParseExecuteStmt()
	Next();
	Return ExecuteStmt(ParseExpression());
EndFunction // ParseExecuteStmt()

Function ParseAssignOrCallStmt()
	Var Left, Right, Stmt, NewVar;
	Left = ParseDesigExpr(True, NewVar);
	If Left.Call Then
		Stmt = CallStmt(Left);
	Else
		Expect(Tokens.Eql);
		Next();
		Right = ParseExpression();
		If NewVar <> Undefined Then
			Parser_Vars.Insert(NewVar.Name, NewVar);
			Parser_Scope.Auto.Add(NewVar);
		EndIf;
		Stmt = AssignStmt(Left, Right);
	EndIf;
	Return Stmt;
EndFunction // ParseAssignOrCallStmt()

Function ParseIfStmt()
	Var Tok, Cond, ThenPart, ElsePart;
	Var ElsIfPart, ElsIfCond, ElsIfThen, Pos, Line;
	Next();
	Cond = ParseExpression();
	Expect(Tokens.Then);
	Next();
	ThenPart = ParseStatements();
	Tok = Parser_Tok;
	If Tok = Tokens.ElsIf Then
		ElsIfPart = New Array;
		While Tok = Tokens.ElsIf Do
			Pos = Parser_BegPos;
			Line = Parser_Line;
			Next();
			ElsIfCond = ParseExpression();
			Expect(Tokens.Then);
			Next();
			ElsIfThen = ParseStatements();
			ElsIfPart.Add(ElsIfStmt(ElsIfCond, ElsIfThen, Place(Pos, Line)));
			Tok = Parser_Tok;
		EndDo;
	EndIf;
	If Tok = Tokens.Else Then
		Next();
		ElsePart = ParseStatements();
	EndIf;
	Expect(Tokens.EndIf);
	Next();
	Return IfStmt(Cond, ThenPart, ElsIfPart, ElsePart);
EndFunction // ParseIfStmt()

Function ParseTryStmt()
	Var TryPart, ExceptPart;
	Next();
	TryPart = ParseStatements();
	Expect(Tokens.Except);
	Next();
	ExceptPart = ParseStatements();
	Expect(Tokens.EndTry);
	Next();
	Return TryStmt(TryPart, ExceptPart);
EndFunction // ParseTryStmt()

Function ParseWhileStmt()
	Var Cond, Statements;
	Next();
	Cond = ParseExpression();
	Expect(Tokens.Do);
	Next();
	Statements = ParseStatements();
	Expect(Tokens.EndDo);
	Next();
	Return WhileStmt(Cond, Statements);
EndFunction // ParseWhileStmt()

Function ParseForStmt()
	Var DesigExpr, From, Until, Statements, VarPos, NewVar;
	Expect(Tokens.Ident);
	VarPos = Parser_BegPos;
	DesigExpr = ParseDesigExpr(True, NewVar);
	If DesigExpr.Call Then
		Error("Expected variable", VarPos, True);
	EndIf;
	Expect(Tokens.Eql);
	Next();
	From = ParseExpression();
	Expect(Tokens.To);
	Next();
	Until = ParseExpression();
	If NewVar <> Undefined Then
		Parser_Vars.Insert(NewVar.Name, NewVar);
		Parser_Scope.Auto.Add(NewVar);
	EndIf;
	Expect(Tokens.Do);
	Next();
	Statements = ParseStatements();
	Expect(Tokens.EndDo);
	Next();
	Return ForStmt(DesigExpr, From, Until, Statements);
EndFunction // ParseForStmt()

Function ParseForEachStmt()
	Var DesigExpr, Collection, Statements, VarPos, NewVar;
	Next();
	Expect(Tokens.Ident);
	VarPos = Parser_BegPos;
	DesigExpr = ParseDesigExpr(True, NewVar);
	If DesigExpr.Call Then
		Error("Expected variable", VarPos, True);
	EndIf;
	Expect(Tokens.In);
	Next();
	Collection = ParseExpression();
	If NewVar <> Undefined Then
		Parser_Vars.Insert(NewVar.Name, NewVar);
		Parser_Scope.Auto.Add(NewVar);
	EndIf;
	Expect(Tokens.Do);
	Next();
	Statements = ParseStatements();
	Expect(Tokens.EndDo);
	Next();
	Return ForEachStmt(DesigExpr, Collection, Statements);
EndFunction // ParseForEachStmt()

Function ParseGotoStmt()
	Var Label;
	Next();
	Expect(Tokens.Label);
	Label = Parser_Lit;
	Next();
	Return GotoStmt(Label);
EndFunction // ParseGotoStmt()

Function ParseReturnStmt()
	Var Expr, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Next();
	If Parser_IsFunc Then
		Expr = ParseExpression();
	EndIf;
	Return ReturnStmt(Expr, Place(Pos, Line));
EndFunction // ParseReturnStmt()

#EndRegion // ParseStmt

#Region ParsePrep

// Expr

Function ParsePrepExpression()
	Var Expr, Operator, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Expr = ParsePrepAndExpr();
	While Parser_Tok = Tokens.Or Do
		Operator = Parser_Tok;
		Next();
		Expr = PrepBinaryExpr(Expr, Operator, ParsePrepAndExpr(), Place(Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParsePrepExpression()

Function ParsePrepAndExpr()
	Var Expr, Operator, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Expr = ParsePrepNotExpr();
	While Parser_Tok = Tokens.And Do
		Operator = Parser_Tok;
		Next();
		Expr = PrepBinaryExpr(Expr, Operator, ParsePrepNotExpr(), Place(Pos, Line));
	EndDo;
	Return Expr;
EndFunction // ParsePrepAndExpr()

Function ParsePrepNotExpr()
	Var Expr, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	If Parser_Tok = Tokens.Not Then
		Next();
		Expr = PrepNotExpr(ParsePrepSymExpr(), Place(Pos, Line));
	Else
		Expr = ParsePrepSymExpr();
	EndIf;
	Return Expr;
EndFunction // ParsePrepNotExpr()

Function ParsePrepSymExpr()
	Var Operand, SymbolExist;
	If Parser_Tok = Tokens.Ident Then
		SymbolExist = PrepSymbols.Property(Parser_Lit);
		Operand = PrepSymExpr(Parser_Lit, SymbolExist, Place());
		Next();
	Else
		Error("Expected preprocessor symbol",, True);
	EndIf;
	Return Operand;
EndFunction // ParsePrepSymExpr()

// Inst

Function ParsePrepUseInst()
	Var Path, Pos, Line;
	Pos = Parser_BegPos;
	Line = Parser_Line;
	Next();
	If Line <> Parser_Line Then
		Error("Expected string or identifier", Parser_EndPos, True);
	EndIf;
	If Parser_Tok = Tokens.Number Then
		Path = Parser_Lit;
		If AlphaDigitMap[Parser_Char] = Alpha Then // can be a keyword
			Next();
			Path = Path + Parser_Lit;
		EndIf;
	ElsIf Parser_Tok = Tokens.Ident
		Or Parser_Tok = Tokens.String Then
		Path = Parser_Lit;
	Else
		Error("Expected string or identifier", Parser_EndPos, True);
	EndIf;
	Next();
	Return PrepUseInst(Path, Place(Pos, Line));
EndFunction // ParsePrepUseInst()

Function ParsePrepIfInst()
	Var Cond;
	Next();
	Cond = ParsePrepExpression();
	Expect(Tokens.Then);
	Parser_Tok = Tokens.Semicolon; // cheat code
	Return PrepIfInst(Cond);
EndFunction // ParsePrepIfInst()

Function ParsePrepElsIfInst()
	Var Cond;
	Next();
	Cond = ParsePrepExpression();
	Expect(Tokens.Then);
	Parser_Tok = Tokens.Semicolon; // cheat code
	Return PrepElsIfInst(Cond);
EndFunction // ParsePrepElsIfInst()

Function ParsePrepRegionInst()
	Var Name;
	Next();
	Expect(Tokens.Ident);
	Name = Parser_Lit;
	Parser_Tok = Tokens.Semicolon; // cheat code
	Return PrepRegionInst(Name);
EndFunction // ParsePrepRegionInst()

#EndRegion // ParsePrep

#EndRegion // Parser

#Region Auxiliary

Function Place(Pos = Undefined, Line = Undefined)
	Var Place, Len;
	If Location Then
		If Pos = Undefined Then
			Len = StrLen(Parser_Lit);
			Pos = Parser_Pos - Len;
		Else
			Len = Parser_EndPos - Pos;
		EndIf;
		If Line = Undefined Then
			Line = Parser_Line;
		EndIf;
		Place = New Structure(
			"Pos,"     // number
			"Len,"     // number
			"BegLine," // number
			"EndLine"  // number
		, Pos, Len, Line, Parser_EndLine);
		If Debug Then
			Place.Insert("Str", Mid(Parser_Source, Pos, Len));
		EndIf;
	Else
		Place = Line;
	EndIf;
	Return Place;
EndFunction // Place()

Function AsDate(DateLit)
	Var List, Char, Num;
	List = New Array;
	For Num = 1 To StrLen(DateLit) Do
		Char = Mid(DateLit, Num, 1);
		If AlphaDigitMap[Char] = Digit Then
			List.Add(Char);
		EndIf;
	EndDo;
	Return Date(StrConcat(List));
EndFunction // AsDate()

Procedure Expect(Tok)
	If Parser_Tok <> Tok Then
		Error("Expected " + Tok,, True);
	EndIf;
EndProcedure // Expect()

Function StringToken(Lit)
	Var Tok;
	If Left(Lit, 1) = """" Then
		If Right(Lit, 1) = """" Then
			Tok = Tokens.String;
		Else
			Tok = Tokens.StringBeg;
		EndIf;
	Else // |
		If Right(Lit, 1) = """" Then
			Tok = Tokens.StringEnd;
		Else
			Tok = Tokens.StringMid;
		EndIf;
	EndIf;
	Return Tok;
EndFunction // StringToken()

Procedure Error(Note, Pos = Undefined, Stop = False)
	Var ErrorText;
	If Pos = Undefined Then
		Pos = Min(Parser_Pos - StrLen(Parser_Lit), Parser_Len);
	EndIf;
	ErrorText = StrTemplate("[ Ln: %1; Col: %2 ] %3",
		StrOccurrenceCount(Mid(Parser_Source, 1, Pos), Chars.LF) + 1,
		Pos - ?(Pos = 0, 0, StrFind(Parser_Source, Chars.LF, SearchDirection.FromEnd, Pos)),
		Note
	);
	If Stop Then
		Raise ErrorText;
	Else
		Message(ErrorText);
	EndIf;
EndProcedure // Error()

#EndRegion // Auxiliary

#Region Visitor

Function Visitor(Hooks) Export
	Var Counters, Item;

	Visitor_Hooks = Hooks;
	Visitor_Stack = New FixedStructure("Outer, Parent", Undefined, Undefined);

	Counters = New Structure;
	Visitor_Counters = Counters;
	For Each Item In Nodes Do
		Counters.Insert(Item.Key, 0);
	EndDo;

	Return Undefined;
EndFunction // Visitor()

Procedure PushInfo(Parent)
	Var NodeType;
	Visitor_Stack = New FixedStructure("Outer, Parent", Visitor_Stack, Parent);
	NodeType = Parent.Type;
	Visitor_Counters[NodeType] = Visitor_Counters[NodeType] + 1;
EndProcedure // PushInfo()

Procedure PopInfo()
	Var NodeType;
	NodeType = Visitor_Stack.Parent.Type;
	Visitor_Counters[NodeType] = Visitor_Counters[NodeType] - 1;
	Visitor_Stack = Visitor_Stack.Outer;
EndProcedure // PopInfo()

Function Hooks() Export
	Var Hooks, Item;

	Hooks = New Structure(
		"VisitModule,         AfterVisitModule,"
		"VisitDeclarations,   AfterVisitDeclarations,"
		"VisitStatements,     AfterVisitStatements,"
		"VisitDecl,           AfterVisitDecl,"
		"VisitVarModDecl,     AfterVisitVarModDecl,"
		"VisitVarLocDecl,     AfterVisitVarLocDecl,"
		"VisitProcDecl,       AfterVisitProcDecl,"
		"VisitFuncDecl,       AfterVisitFuncDecl,"
		"VisitExpr,           AfterVisitExpr,"
		"VisitBasicLitExpr,   AfterVisitBasicLitExpr,"
		"VisitDesigExpr,      AfterVisitDesigExpr,"
		"VisitUnaryExpr,      AfterVisitUnaryExpr,"
		"VisitBinaryExpr,     AfterVisitBinaryExpr,"
		"VisitNewExpr,        AfterVisitNewExpr,"
		"VisitTernaryExpr,    AfterVisitTernaryExpr,"
		"VisitParenExpr,      AfterVisitParenExpr,"
		"VisitNotExpr,        AfterVisitNotExpr,"
		"VisitStringExpr,     AfterVisitStringExpr,"
		"VisitStmt,           AfterVisitStmt,"
		"VisitAssignStmt,     AfterVisitAssignStmt,"
		"VisitReturnStmt,     AfterVisitReturnStmt,"
		"VisitBreakStmt,      AfterVisitBreakStmt,"
		"VisitContinueStmt,   AfterVisitContinueStmt,"
		"VisitRaiseStmt,      AfterVisitRaiseStmt,"
		"VisitExecuteStmt,    AfterVisitExecuteStmt,"
		"VisitCallStmt,       AfterVisitCallStmt,"
		"VisitIfStmt,         AfterVisitIfStmt,"
		"VisitElsIfStmt,      AfterVisitElsIfStmt,"
		"VisitWhileStmt,      AfterVisitWhileStmt,"
		"VisitForStmt,        AfterVisitForStmt,"
		"VisitForEachStmt,    AfterVisitForEachStmt,"
		"VisitTryStmt,        AfterVisitTryStmt,"
		"VisitGotoStmt,       AfterVisitGotoStmt,"
		"VisitLabelStmt,      AfterVisitLabelStmt,"
		"VisitPrepInst,       AfterVisitPrepInst,"
		"VisitPrepExpr,       AfterVisitPrepExpr,"
		"VisitPrepBinaryExpr, AfterVisitPrepBinaryExpr,"
		"VisitPrepNotExpr,    AfterVisitPrepNotExpr,"
		"VisitPrepSymExpr,    AfterVisitPrepSymExpr"
	);
	For Each Item In Hooks Do
		Hooks[Item.Key] = New Array;
	EndDo;

	Return Hooks;

EndFunction // Hooks()

Procedure VisitModule(Module) Export
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitModule Do
		Hook.VisitModule(Module, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(Module);
	VisitDeclarations(Module.Decls);
	VisitStatements(Module.Body);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitModule Do
		Hook.AfterVisitModule(Module, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitModule()

Procedure VisitDeclarations(Declarations)
	Var Decl, Hook;
	For Each Hook In Visitor_Hooks.VisitDeclarations Do
		Hook.VisitDeclarations(Declarations, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Decl In Declarations Do
		VisitDecl(Decl);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitDeclarations Do
		Hook.AfterVisitDeclarations(Declarations, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitDeclarations()

Procedure VisitStatements(Statements)
	Var Stmt, Hook;
	For Each Hook In Visitor_Hooks.VisitStatements Do
		Hook.VisitStatements(Statements, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Stmt In Statements Do
		VisitStmt(Stmt);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitStatements Do
		Hook.AfterVisitStatements(Statements, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitStatements()

#Region VisitDecl

Procedure VisitDecl(Decl)
	Var Type, Hook;
	For Each Hook In Visitor_Hooks.VisitDecl Do
		Hook.VisitDecl(Decl, Visitor_Stack, Visitor_Counters);
	EndDo;
	Type = Decl.Type;
	If Type = Nodes.VarModDecl Then
		VisitVarModDecl(Decl);
	ElsIf Type = Nodes.VarLocDecl Then
		VisitVarLocDecl(Decl);
	ElsIf Type = Nodes.ProcDecl Then
		VisitProcDecl(Decl);
	ElsIf Type = Nodes.FuncDecl Then
		VisitFuncDecl(Decl);
	ElsIf Type = Nodes.PrepRegionInst
		Or Type = Nodes.PrepEndRegionInst
		Or Type = Nodes.PrepIfInst
		Or Type = Nodes.PrepElsIfInst
		Or Type = Nodes.PrepElseInst
		Or Type = Nodes.PrepEndIfInst
		Or Type = Nodes.PrepUseInst Then
		VisitPrepInst(Decl);
	EndIf;
	For Each Hook In Visitor_Hooks.AfterVisitDecl Do
		Hook.AfterVisitDecl(Decl, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitDecl()

Procedure VisitVarModDecl(VarModDecl)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitVarModDecl Do
		Hook.VisitVarModDecl(VarModDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitVarModDecl Do
		Hook.AfterVisitVarModDecl(VarModDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitVarModDecl()

Procedure VisitVarLocDecl(VarLocDecl)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitVarLocDecl Do
		Hook.VisitVarLocDecl(VarLocDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitVarLocDecl Do
		Hook.AfterVisitVarLocDecl(VarLocDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitVarLocDecl()

Procedure VisitProcDecl(ProcDecl)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitProcDecl Do
		Hook.VisitProcDecl(ProcDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(ProcDecl);
	VisitDeclarations(ProcDecl.Decls);
	VisitStatements(ProcDecl.Body);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitProcDecl Do
		Hook.AfterVisitProcDecl(ProcDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitProcDecl()

Procedure VisitFuncDecl(FuncDecl)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitFuncDecl Do
		Hook.VisitFuncDecl(FuncDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(FuncDecl);
	VisitDeclarations(FuncDecl.Decls);
	VisitStatements(FuncDecl.Body);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitFuncDecl Do
		Hook.AfterVisitFuncDecl(FuncDecl, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitFuncDecl()

#EndRegion // VisitDecl

#Region VisitExpr

Procedure VisitExpr(Expr)
	Var Type, Hook;
	For Each Hook In Visitor_Hooks.VisitExpr Do
		Hook.VisitExpr(Expr, Visitor_Stack, Visitor_Counters);
	EndDo;
	Type = Expr.Type;
	If Type = Nodes.BasicLitExpr Then
		VisitBasicLitExpr(Expr);
	ElsIf Type = Nodes.DesigExpr Then
		VisitDesigExpr(Expr);
	ElsIf Type = Nodes.UnaryExpr Then
		VisitUnaryExpr(Expr);
	ElsIf Type = Nodes.BinaryExpr Then
		VisitBinaryExpr(Expr);
	ElsIf Type = Nodes.NewExpr Then
		VisitNewExpr(Expr);
	ElsIf Type = Nodes.TernaryExpr Then
		VisitTernaryExpr(Expr);
	ElsIf Type = Nodes.ParenExpr Then
		VisitParenExpr(Expr);
	ElsIf Type = Nodes.NotExpr Then
		VisitNotExpr(Expr);
	ElsIf Type = Nodes.StringExpr Then
		VisitStringExpr(Expr);
	EndIf;
	For Each Hook In Visitor_Hooks.AfterVisitExpr Do
		Hook.AfterVisitExpr(Expr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitExpr()

Procedure VisitBasicLitExpr(BasicLitExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitBasicLitExpr Do
		Hook.VisitBasicLitExpr(BasicLitExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitBasicLitExpr Do
		Hook.AfterVisitBasicLitExpr(BasicLitExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitBasicLitExpr()

Procedure VisitDesigExpr(DesigExpr)
	Var SelectExpr, Expr, Hook;
	For Each Hook In Visitor_Hooks.VisitDesigExpr Do
		Hook.VisitDesigExpr(DesigExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(DesigExpr);
	For Each SelectExpr In DesigExpr.Select Do
		If SelectExpr.Kind = SelectKinds.Index Then
			VisitExpr(SelectExpr.Value);
		ElsIf SelectExpr.Kind = SelectKinds.Call Then
			For Each Expr In SelectExpr.Value Do
				If Expr <> Undefined Then
					VisitExpr(Expr);
				EndIf;
			EndDo;
		EndIf;
	EndDo;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitDesigExpr Do
		Hook.AfterVisitDesigExpr(DesigExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitDesigExpr()

Procedure VisitUnaryExpr(UnaryExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitUnaryExpr Do
		Hook.VisitUnaryExpr(UnaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(UnaryExpr);
	VisitExpr(UnaryExpr.Operand);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitUnaryExpr Do
		Hook.AfterVisitUnaryExpr(UnaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitUnaryExpr()

Procedure VisitBinaryExpr(BinaryExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitBinaryExpr Do
		Hook.VisitBinaryExpr(BinaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(BinaryExpr);
	VisitExpr(BinaryExpr.Left);
	VisitExpr(BinaryExpr.Right);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitBinaryExpr Do
		Hook.AfterVisitBinaryExpr(BinaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitBinaryExpr()

Procedure VisitNewExpr(NewExpr)
	Var Expr, Hook;
	For Each Hook In Visitor_Hooks.VisitNewExpr Do
		Hook.VisitNewExpr(NewExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(NewExpr);
	For Each Expr In NewExpr.Args Do
		If Expr <> Undefined Then
			VisitExpr(Expr);
		EndIf;
	EndDo;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitNewExpr Do
		Hook.AfterVisitNewExpr(NewExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitNewExpr()

Procedure VisitTernaryExpr(TernaryExpr)
	Var SelectExpr, Expr, Hook;
	For Each Hook In Visitor_Hooks.VisitTernaryExpr Do
		Hook.VisitTernaryExpr(TernaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(TernaryExpr);
	VisitExpr(TernaryExpr.Cond);
	VisitExpr(TernaryExpr.Then);
	VisitExpr(TernaryExpr.Else);
	For Each SelectExpr In TernaryExpr.Select Do
		If SelectExpr.Kind <> SelectKinds.Ident Then
			For Each Expr In SelectExpr.Value Do
				If Expr <> Undefined Then
					VisitExpr(Expr);
				EndIf;
			EndDo;
		EndIf;
	EndDo;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitTernaryExpr Do
		Hook.AfterVisitTernaryExpr(TernaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitTernaryExpr()

Procedure VisitParenExpr(ParenExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitParenExpr Do
		Hook.VisitParenExpr(ParenExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(ParenExpr);
	VisitExpr(ParenExpr.Expr);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitParenExpr Do
		Hook.AfterVisitParenExpr(ParenExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitParenExpr()

Procedure VisitNotExpr(NotExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitNotExpr Do
		Hook.VisitNotExpr(NotExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(NotExpr);
	VisitExpr(NotExpr.Expr);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitNotExpr Do
		Hook.AfterVisitNotExpr(NotExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitNotExpr()

Procedure VisitStringExpr(StringExpr)
	Var Expr, Hook;
	For Each Hook In Visitor_Hooks.VisitStringExpr Do
		Hook.VisitStringExpr(StringExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(StringExpr);
	For Each Expr In StringExpr.List Do
		VisitBasicLitExpr(Expr);
	EndDo;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitStringExpr Do
		Hook.AfterVisitStringExpr(StringExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitStringExpr()

#EndRegion // VisitExpr

#Region VisitStmt

Procedure VisitStmt(Stmt)
	Var Type, Hook;
	For Each Hook In Visitor_Hooks.VisitStmt Do
		Hook.VisitStmt(Stmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	Type = Stmt.Type;
	If Type = Nodes.AssignStmt Then
		VisitAssignStmt(Stmt);
	ElsIf Type = Nodes.ReturnStmt Then
		VisitReturnStmt(Stmt);
	ElsIf Type = Nodes.BreakStmt Then
		VisitBreakStmt(Stmt);
	ElsIf Type = Nodes.ContinueStmt Then
		VisitContinueStmt(Stmt);
	ElsIf Type = Nodes.RaiseStmt Then
		VisitRaiseStmt(Stmt);
	ElsIf Type = Nodes.ExecuteStmt Then
		VisitExecuteStmt(Stmt);
	ElsIf Type = Nodes.CallStmt Then
		VisitCallStmt(Stmt);
	ElsIf Type = Nodes.IfStmt Then
		VisitIfStmt(Stmt);
	ElsIf Type = Nodes.WhileStmt Then
		VisitWhileStmt(Stmt);
	ElsIf Type = Nodes.ForStmt Then
		VisitForStmt(Stmt);
	ElsIf Type = Nodes.ForEachStmt Then
		VisitForEachStmt(Stmt);
	ElsIf Type = Nodes.TryStmt Then
		VisitTryStmt(Stmt);
	ElsIf Type = Nodes.GotoStmt Then
		VisitGotoStmt(Stmt);
	ElsIf Type = Nodes.LabelStmt Then
		VisitLabelStmt(Stmt);
	ElsIf Type = Nodes.PrepRegionInst
		Or Type = Nodes.PrepEndRegionInst
		Or Type = Nodes.PrepIfInst
		Or Type = Nodes.PrepElsIfInst
		Or Type = Nodes.PrepElseInst
		Or Type = Nodes.PrepEndIfInst Then
		VisitPrepInst(Stmt);
	EndIf;
	For Each Hook In Visitor_Hooks.AfterVisitStmt Do
		Hook.AfterVisitStmt(Stmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitStmt()

Procedure VisitAssignStmt(AssignStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitAssignStmt Do
		Hook.VisitAssignStmt(AssignStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(AssignStmt);
	VisitDesigExpr(AssignStmt.Left);
	VisitExpr(AssignStmt.Right);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitAssignStmt Do
		Hook.AfterVisitAssignStmt(AssignStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitAssignStmt()

Procedure VisitReturnStmt(ReturnStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitReturnStmt Do
		Hook.VisitReturnStmt(ReturnStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(ReturnStmt);
	If ReturnStmt.Expr <> Undefined Then
		VisitExpr(ReturnStmt.Expr);
	EndIf;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitReturnStmt Do
		Hook.AfterVisitReturnStmt(ReturnStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitReturnStmt()

Procedure VisitBreakStmt(BreakStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitBreakStmt Do
		Hook.VisitBreakStmt(BreakStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitBreakStmt Do
		Hook.AfterVisitBreakStmt(BreakStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitBreakStmt()

Procedure VisitContinueStmt(ContinueStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitContinueStmt Do
		Hook.VisitContinueStmt(ContinueStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitContinueStmt Do
		Hook.AfterVisitContinueStmt(ContinueStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitContinueStmt()

Procedure VisitRaiseStmt(RaiseStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitRaiseStmt Do
		Hook.VisitRaiseStmt(RaiseStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(RaiseStmt);
	If RaiseStmt.Expr <> Undefined Then
		VisitExpr(RaiseStmt.Expr);
	EndIf;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitRaiseStmt Do
		Hook.AfterVisitRaiseStmt(RaiseStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitRaiseStmt()

Procedure VisitExecuteStmt(ExecuteStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitExecuteStmt Do
		Hook.VisitExecuteStmt(ExecuteStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(ExecuteStmt);
	VisitExpr(ExecuteStmt.Expr);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitExecuteStmt Do
		Hook.AfterVisitExecuteStmt(ExecuteStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitExecuteStmt()

Procedure VisitCallStmt(CallStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitCallStmt Do
		Hook.VisitCallStmt(CallStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(CallStmt);
	VisitDesigExpr(CallStmt.Desig);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitCallStmt Do
		Hook.AfterVisitCallStmt(CallStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitCallStmt()

Procedure VisitIfStmt(IfStmt)
	Var ElsIfStmt, Hook;
	For Each Hook In Visitor_Hooks.VisitIfStmt Do
		Hook.VisitIfStmt(IfStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(IfStmt);
	VisitExpr(IfStmt.Cond);
	VisitStatements(IfStmt.Then);
	If IfStmt.ElsIf <> Undefined Then
		For Each ElsIfStmt In IfStmt.ElsIf Do
			VisitElsIfStmt(ElsIfStmt);
		EndDo;
	EndIf;
	If IfStmt.Else <> Undefined Then
		VisitStatements(IfStmt.Else);
	EndIf;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitIfStmt Do
		Hook.AfterVisitIfStmt(IfStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitIfStmt()

Procedure VisitElsIfStmt(ElsIfStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitElsIfStmt Do
		Hook.VisitElsIfStmt(ElsIfStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(ElsIfStmt);
	VisitExpr(ElsIfStmt.Cond);
	VisitStatements(ElsIfStmt.Then);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitElsIfStmt Do
		Hook.AfterVisitElsIfStmt(ElsIfStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitElsIfStmt()

Procedure VisitWhileStmt(WhileStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitWhileStmt Do
		Hook.VisitWhileStmt(WhileStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(WhileStmt);
	VisitExpr(WhileStmt.Cond);
	VisitStatements(WhileStmt.Body);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitWhileStmt Do
		Hook.AfterVisitWhileStmt(WhileStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitWhileStmt()

Procedure VisitForStmt(ForStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitForStmt Do
		Hook.VisitForStmt(ForStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(ForStmt);
	VisitDesigExpr(ForStmt.Desig);
	VisitExpr(ForStmt.From);
	VisitExpr(ForStmt.To);
	VisitStatements(ForStmt.Body);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitForStmt Do
		Hook.AfterVisitForStmt(ForStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitForStmt()

Procedure VisitForEachStmt(ForEachStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitForEachStmt Do
		Hook.VisitForEachStmt(ForEachStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(ForEachStmt);
	VisitDesigExpr(ForEachStmt.Desig);
	VisitExpr(ForEachStmt.In);
	VisitStatements(ForEachStmt.Body);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitForEachStmt Do
		Hook.AfterVisitForEachStmt(ForEachStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitForEachStmt()

Procedure VisitTryStmt(TryStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitTryStmt Do
		Hook.VisitTryStmt(TryStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(TryStmt);
	VisitStatements(TryStmt.Try);
	VisitStatements(TryStmt.Except);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitTryStmt Do
		Hook.AfterVisitTryStmt(TryStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitTryStmt()

Procedure VisitGotoStmt(GotoStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitGotoStmt Do
		Hook.VisitGotoStmt(GotoStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitGotoStmt Do
		Hook.AfterVisitGotoStmt(GotoStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitGotoStmt()

Procedure VisitLabelStmt(LabelStmt)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitLabelStmt Do
		Hook.VisitLabelStmt(LabelStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitLabelStmt Do
		Hook.AfterVisitLabelStmt(LabelStmt, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitLabelStmt()

#EndRegion // VisitStmt

#Region VisitPrep

Procedure VisitPrepExpr(PrepExpr)
	Var Type, Hook;
	For Each Hook In Visitor_Hooks.VisitPrepExpr Do
		Hook.VisitPrepExpr(PrepExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	Type = PrepExpr.Type;
	If Type = Nodes.PrepSymExpr Then
		VisitPrepSymExpr(PrepExpr);
	ElsIf Type = Nodes.PrepBinaryExpr Then
		VisitPrepBinaryExpr(PrepExpr);
	ElsIf Type = Nodes.PrepNotExpr Then
		VisitPrepNotExpr(PrepExpr);
	EndIf;
	For Each Hook In Visitor_Hooks.AfterVisitPrepExpr Do
		Hook.AfterVisitPrepExpr(PrepExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitPrepExpr()

Procedure VisitPrepSymExpr(PrepSymExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitPrepSymExpr Do
		Hook.VisitPrepSymExpr(PrepSymExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	For Each Hook In Visitor_Hooks.AfterVisitPrepSymExpr Do
		Hook.AfterVisitPrepSymExpr(PrepSymExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitPrepSymExpr()

Procedure VisitPrepBinaryExpr(PrepBinaryExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitPrepBinaryExpr Do
		Hook.VisitPrepBinaryExpr(PrepBinaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(PrepBinaryExpr);
	VisitPrepExpr(PrepBinaryExpr.Left);
	VisitPrepExpr(PrepBinaryExpr.Right);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitPrepBinaryExpr Do
		Hook.AfterVisitPrepBinaryExpr(PrepBinaryExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitPrepBinaryExpr()

Procedure VisitPrepNotExpr(PrepNotExpr)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitPrepNotExpr Do
		Hook.VisitPrepNotExpr(PrepNotExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(PrepNotExpr);
	VisitPrepExpr(PrepNotExpr.Expr);
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitPrepNotExpr Do
		Hook.AfterVisitPrepNotExpr(PrepNotExpr, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitPrepNotExpr()

Procedure VisitPrepInst(PrepInst)
	Var Hook;
	For Each Hook In Visitor_Hooks.VisitPrepInst Do
		Hook.VisitPrepInst(PrepInst, Visitor_Stack, Visitor_Counters);
	EndDo;
	PushInfo(PrepInst);
	If PrepInst.Property("Cond") Then
		VisitPrepExpr(PrepInst.Cond);
	EndIf;
	PopInfo();
	For Each Hook In Visitor_Hooks.AfterVisitPrepInst Do
		Hook.AfterVisitPrepInst(PrepInst, Visitor_Stack, Visitor_Counters);
	EndDo;
EndProcedure // VisitPrepInst()

#EndRegion // VisitPrep

#EndRegion // Visitor

Init();
