#Область ОписаниеПеременных
 
&НаКлиенте
Перем Компонент;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Компонент = РаботаСКомпонентомСканераШтрихкодов.ПодключитьКомпонент();
	Если Компонент <> Неопределено Тогда 
		
		Компонент.StartGetScan();           
	КонецЕсли;
	
	Элементы.КартинкаЧО01ВвестиШтрихкод.Видимость = (Компонент = Неопределено);
КонецПроцедуры


&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)                 
	
	Если Событие = "BarcodeDecodeData" И ВводДоступен() тогда 
		
		ОбработатьВводШтрихкодаНаКлиенте(Данные);			
		Закрыть();		
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Компонент = Неопределено;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КартинкаЧО01ВвестиШтрихкодНажатие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеВводаШтрихкода", ЭтотОбъект);
	Подсказка = "Введите штрихкод";	
	
	ПоказатьВводСтроки(ОписаниеОповещения, "", Подсказка, 32);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьОтгрузочныйЛистПоШтрихкоду(Знач Штрихкод)
			
	Штрихкод = 	Лев(Штрихкод, 8) + "-" + 
			Сред(Штрихкод, 9, 4) + "-" + 
			Сред(Штрихкод, 13, 4) + "-" + 
			Сред(Штрихкод, 17, 4) + "-" + 
			Прав(Штрихкод, 12);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ОтгрузочныйЛист.Ссылка
		|ИЗ
		|	Документ.ОтгрузочныйЛист КАК ОтгрузочныйЛист
		|ГДЕ
		|	ОтгрузочныйЛист.ЗаказПокупателя = &Штрихкод";
	
	Запрос.УстановитьПараметр("Штрихкод", Штрихкод);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЦикла;		
	Возврат Неопределено;
КонецФункции


&НаСервере
Функция СоздатьОтгрузочныйЛистНаСервере(Знач Штрихкод)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ДанныеОтгрузочногоЛиста = ОбменДанными.ПолучитьДанныеОтгрузочногоЛиста(Штрихкод);
	
	Если ДанныеОтгрузочногоЛиста.Свойство("number") Тогда 
		
		Штрихкод = 	Лев(Штрихкод, 8) + "-" + 
			Сред(Штрихкод, 9, 4) + "-" + 
			Сред(Штрихкод, 13, 4) + "-" + 
			Сред(Штрихкод, 17, 4) + "-" + 
			Прав(Штрихкод, 12);
		
		ОтгрузочныйЛист = Документы.ОтгрузочныйЛист.СоздатьДокумент();
		
		//ОтгрузочныйЛист.УстановитьСсылкуНового(Документы.ОтгрузочныйЛист.ПолучитьСсылку(Новый УникальныйИдентификатор(Штрихкод)));
		ОтгрузочныйЛист.ЗаказПокупателя = ДанныеОтгрузочногоЛиста.order_id;
		ОтгрузочныйЛист.Номер = ДанныеОтгрузочногоЛиста.number;
		ОтгрузочныйЛист.Дата = XMLЗначение(Тип("Дата"), ДанныеОтгрузочногоЛиста.date);
		ОтгрузочныйЛист.Штрихкод = ДанныеОтгрузочногоЛиста.barcode;
				
		
		Для Каждого item Из ДанныеОтгрузочногоЛиста.items Цикл 
			
			НоваяСтрока = ОтгрузочныйЛист.СборочныеЛисты.Добавить();
			НоваяСтрока.Штрихкод = item.barcode;
			НоваяСтрока.Номер = item.number;
			НоваяСтрока.Идентификатор = item.id;
		КонецЦикла;

		ОтгрузочныйЛист.Записать();		                                 
		Возврат ОтгрузочныйЛист.Ссылка;
	КонецЕсли;
	Возврат Неопределено;
КонецФункции

&НаКлиенте
Процедура ОткрытьФормуНовогоДокумента(Штрихкод)
	
	Попытка
		ОтгрузочныйЛист = СоздатьОтгрузочныйЛистНаСервере(Штрихкод);
	Исключение
		
		ОтгрузочныйЛист = Неопределено;
	КонецПопытки;
	
	Если ЗначениеЗаполнено(ОтгрузочныйЛист) Тогда
		
		ОткрытьФорму("Документ.ОтгрузочныйЛист.Форма.ФормаДокумента", Новый Структура("Ключ", ОтгрузочныйЛист));
	Иначе
		
		Сообщить("Ошибка создания отгрузочного листа");
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВводШтрихкодаНаКлиенте(Штрихкод)
	
	ОтгрузочныйЛист = ПолучитьОтгрузочныйЛистПоШтрихкоду(Штрихкод);
	Если ЗначениеЗаполнено(ОтгрузочныйЛист) Тогда 
		
		ОткрытьФорму("Документ.ОтгрузочныйЛист.Форма.ФормаДокумента", Новый Структура("Ключ", ОтгрузочныйЛист));
	Иначе                                     
		
		ОткрытьФормуНовогоДокумента(Штрихкод);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПослеВводаШтрихкода(Штрихкод, Параметры) Экспорт
    Если НЕ Штрихкод = Неопределено Тогда
        
		ОбработатьВводШтрихкодаНаКлиенте(Штрихкод)
    КонецЕсли;
КонецПроцедуры

#КонецОбласти
