﻿
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область  ЗагрузкаКурсовВалют

Процедура ЗагрузитьКурсыВалютЗаПериод(ДатаНачала,ДатаОкончания)Экспорт
	
	Соединение = ПолучитьСоединениеСБанком();
	
	ШаблонСтрокиЗапроса = "/api/exchangerates/rates/%1/%2/%3/%4/?format=json";
	
	ВалютаУпрУчета = Константы.ВалютаУправленческогоУчета.Получить();
			
	ВыборкаКурсов = ПолучитьВыборкуВалют();
	
	Пока ВыборкаКурсов.Следующий() Цикл
		
		 ГруппаВалюты	 	= ПолучитьГрупуВалюты(Соединение,ВыборкаКурсов.Наименование);
		
		 СоответствиеКурсов = ПолучитьСоответствиеКурсовВалютПоДатам(Соединение,ВыборкаКурсов.Ссылка,ГруппаВалюты,ДатаНачала,ДатаОкончания,ШаблонСтрокиЗапроса);
		 
		 ОбработатьСоответствияКурсовВалют(СоответствиеКурсов,ВалютаУпрУчета,ВыборкаКурсов.Ссылка);
		           	
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработатьСоответствияКурсовВалют(СоответсвиеКурсаВалюты,ВалютаУпрУчета,Валюта)
	  	
	Для каждого ЭлементКурсаУпр Из СоответсвиеКурсаВалюты Цикл
		
			ЗаписатьКурсыВалют(ЭлементКурсаУпр.Значение,Валюта,ЭлементКурсаУпр.Ключ);
									
	КонецЦикла;
	
КонецПроцедуры

Процедура ПолучитьТекущиеКурсыВалют()Экспорт
	
	Соединение = ПолучитьСоединениеСБанком();

	ВыборкаВалют = ПолучитьВыборкуВалют();
	
	ШаблонСтроки = "api/exchangerates/rates/%1/%2/%3/?format=json";
		
	ДатаВалюты = ТекущаяДатаСеанса()-86400;
	
	Пока ВыборкаВалют.Следующий() Цикл
	
		ГруппаВалюты	 = ПолучитьГрупуВалюты(Соединение,ВыборкаВалют.Наименование);
		
		КурсВалюты 		 = ПолучитьТекущийКурсВалюты(Соединение,ВыборкаВалют.Ссылка,ГруппаВалюты,ШаблонСтроки,ДатаВалюты);
		
		ЗаписатьКурсыВалют(КурсВалюты,ВыборкаВалют.Ссылка,ТекущаяДатаСеанса());
				 
	КонецЦикла;

КонецПроцедуры // ПолучитьТекущиеКурсыВалют()

Функция ПолучитьГрупуВалюты(Соединение,КодВалюты)
	
	МассивГрупВалюты = Новый Массив;
	МассивГрупВалюты.Добавить("a");
	МассивГрупВалюты.Добавить("b");
	МассивГрупВалюты.Добавить("c");
	
	СтрокаГруппыВалюты = "api/exchangerates/tables/%1/";
	
	ГруппаВалюты = "";
	
	Для каждого ТаблицаВалюты Из МассивГрупВалюты Цикл
		
		СтрокаЗапроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаГруппыВалюты,ТаблицаВалюты);
		
		Запрос = Новый HTTPЗапрос(СтрокаЗапроса);
		
		Данные = ВыполнитьЗапросКСервисуКурсовВалют(Соединение,Запрос);
		
		ВалютаПоГруппам = Данные.Получить(0).rates;
		
		Для каждого ЭлементДанных Из ВалютаПоГруппам Цикл
		
			Если ЭлементДанных.code = КодВалюты Тогда
			
				ГруппаВалюты = ТаблицаВалюты;	
				
				Прервать;
				
			КонецЕсли;
						
		КонецЦикла;
		
		Если Не ПустаяСтрока(ГруппаВалюты) Тогда
		
			Прервать;
		
		КонецЕсли;
	
	КонецЦикла;
	
	Возврат ГруппаВалюты 

КонецФункции // ПолучитьГрупуВалюты()

Функция ПолучитьВыборкуВалют()
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	Валюты.Ссылка КАК Ссылка,
	|	Валюты.Код КАК Код,
	|	Валюты.Наименование КАК Наименование
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)"); 
	
	Выборка = Запрос.Выполнить().Выбрать();

	Возврат Выборка 	

КонецФункции // ПолучитьВыборкуВалют()

Функция ПолучитьСоединениеСБанком()
	
	СтрокаСервера = "api.nbp.pl";
	SSL 		  = Новый ЗащищенноеСоединениеOpenSSL(Неопределено,Неопределено);
	Порт		  = 443;	
	
	Соединение = Новый HTTPСоединение(СтрокаСервера,Порт,,,,,SSL);
	
	Возврат  Соединение
	
КонецФункции // ПолучитьСоединениеСБанком()

#Область ОбщегоНазначенияФункции

Процедура ЗаписатьКурсыВалют(КурсВалюты,ВалютаКурса,ДатаКурса)
		
	МенеджерЗаписи = РегистрыСведений.КурсыВалют.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Валюта 			= ВалютаКурса;
	МенеджерЗаписи.Период 			= ДатаКурса;
	МенеджерЗаписи.Курс       	    = КурсВалюты;
	МенеджерЗаписи.Кратность	    = 1;
	МенеджерЗаписи.Записать(Истина);
	
КонецПроцедуры

Функция ПолучитьТекущийКурсВалюты(Соединение,Валюта,ГруппаВалюты,ШаблонСтроки,ДатаВалюты)

	КодВалюты = ПолучитьКодВалюты(Валюта);
	
	МассивРеквизитов = Новый Массив;
	МассивРеквизитов.Добавить(ГруппаВалюты);
	МассивРеквизитов.Добавить(КодВалюты);
	МассивРеквизитов.Добавить(Формат(ДатаВалюты, "ДФ=yyyy-MM-dd"));
	
	МассивКурсов = ПолучитьМассивКурсовВалют(Соединение,ШаблонСтроки,МассивРеквизитов);         
	
	КурсВалюты = 0;
	
	Если МассивКурсов.Количество() Тогда       
			
		 СтрокаКурса = МассивКурсов.Получить(0);
		 
		 КурсВалюты  = СтрокаКурса.mid;
		 
	КонецЕсли;
	
	Возврат КурсВалюты;

КонецФункции

Функция ПолучитьСоответствиеКурсовВалютПоДатам(Соединение,Валюта,Группа,ДатаНачала,ДатаОкончания,ШаблонСтрокиЗапроса)

	СоответствиеКурсов = Новый Соответствие;
	
	КодВалюты = ПолучитьКодВалюты(Валюта);
	
	МассивРеквизитов = Новый Массив;
	МассивРеквизитов.Добавить(Группа);
	МассивРеквизитов.Добавить(КодВалюты);
	МассивРеквизитов.Добавить(Формат(ДатаНачала,"ДФ=yyyy-MM-dd"));
	МассивРеквизитов.Добавить(Формат(ДатаОкончания,"ДФ=yyyy-MM-dd"));
	
	МассивКурсовВалют = ПолучитьМассивКурсовВалют(Соединение,ШаблонСтрокиЗапроса,МассивРеквизитов);
	
	Для каждого СтрокаКурса Из МассивКурсовВалют Цикл
		
		ДатаКурса = ПолучитьДатуИзСтроки(СтрокаКурса.effectiveDate);
		
		СоответствиеКурсов.Вставить(ДатаКурса,СтрокаКурса.mid);
	
	КонецЦикла;
	
	Возврат СоответствиеКурсов
	
КонецФункции // ПолучитьСоответствиеКурсовВалютПоДатам()

Функция ПолучитьМассивКурсовВалют(Соединение,ШаблонСтроки,МассивРеквизитов)
		
	СтрокаЗАпроса = ПолучитьСтрокуЗапроса(ШаблонСтроки,МассивРеквизитов); 
		
	ЗапросКБанку = Новый HTTPЗапрос(СтрокаЗАпроса);
	
	ДанныеКурсов = ВыполнитьЗапросКСервисуКурсовВалют(Соединение,ЗапросКБанку);
	
	МассивКурсов = ДанныеКурсов.rates;         

	Возврат МассивКурсов

КонецФункции // ПолучитьМассивКурсовВалют()

Функция ПолучитьСтрокуЗапроса(ШаблонСтроки,МассивРеквизитовПодСтановки)
	
	СтрокаЗАпроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтрокуИзМассива(ШаблонСтроки,МассивРеквизитовПодСтановки);
	
	Возврат СтрокаЗАпроса

КонецФункции // ПолучитьСтрокуЗапроса()

Функция ПолучитьКодВалюты(Валюта)
	
	КодВалюты = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Валюта,"Наименование"); 

	Возврат КодВалюты

КонецФункции // ПолучитьКодВалюты()

Функция ПолучитьПустуюСтруктуруКурсов()

	Возврат  Новый Структура("rate,units");

КонецФункции

Функция ВыполнитьЗапросКСервисуКурсовВалют(Соединение,Запрос)

	ОтветСоединения = Соединение.Получить(Запрос);
	
	ТекстОтвета = ОтветСоединения.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8);
	
	Если ОтветСоединения.КодСостояния >299 Тогда
		
		ВызватьИсключение(ТекстОтвета);
		
	КонецЕсли;
	
	Данные = ОбработатьJSON(ТекстОтвета);
	
	Возврат Данные	

КонецФункции 

Функция ОбработатьJSON(СтрокаJSON) Экспорт
	
	Результат = Неопределено;
	
	Попытка
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
		Результат = ПрочитатьJSON(ЧтениеJSON, Ложь);
	Исключение
		ЗаписатьЛог(ОписаниеОшибки());
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьДатуИзСтроки(ДатаСтрокой)
	
	СтрокаТолькоЦифры = СтрЗаменить(ДатаСтрокой,"-","");
	
	Возврат Дата(СтрокаТолькоЦифры);

КонецФункции

Функция ЗаписатьЛог(Подробно) Экспорт
		
	ЗаписьЖурналаРегистрации(ЭтотОбъект.Метаданные().Представление(),УровеньЖурналаРегистрации.Ошибка,,,Подробно);
	
КонецФункции

#КонецОбласти 
	
#КонецОбласти 	
	
#Область Регистрация 

Функция СведенияОВнешнейОбработке() Экспорт
	
  Разрешение = РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса("HTTPS","api.nbp.pl/api",443);	
    
  Версия = СтандартныеПодсистемыСервер.ВерсияБиблиотеки();
  
  ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке(Версия);
  
  ПараметрыРегистрации.Вид 				= "ДополнительнаяОбработка";
  ПараметрыРегистрации.Наименование 	= ЭтотОбъект.Метаданные().Представление(); //Наименование обработки, которым будет заполнено наименование элемента справочника
  ПараметрыРегистрации.Версия 			= "1.0";
  ПараметрыРегистрации.БезопасныйРежим 	= Истина;
  ПараметрыРегистрации.Информация 		= ЭтотОбъект.Метаданные().Представление(); //Краткая информация по обработке, описание обработки
  ПараметрыРегистрации.Разрешения.Добавить(Разрешение);
    
  ДобавитьКоманду(ПараметрыРегистрации.Команды,
          ЭтотОбъект.Метаданные().Представление(), //представление команды в пользовательском интерфейсе
          ЭтотОбъект.Метаданные().ПолноеИмя(), //идентификатор команды; любая строка, уникальная в пределах данной обработки
          "ВызовСерверногоМетода");

  СтрокаНастройки = НСтр("ru = настройка';
					  |vi = 'setting';
					  |en = 'setting';
					  |it = 'collocamento';
					  |pl = 'ustawienie'");
  
  СтрокаПредставления = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1 %2",ЭтотОбъект.Метаданные().Представление(),СтрокаНастройки);
  
  СтрокаИдентификатор = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1%2",ЭтотОбъект.Метаданные().Представление(),СтрокаНастройки);
		  
  ДобавитьКоманду(ПараметрыРегистрации.Команды,
          СтрокаПредставления, //представление команды в пользовательском интерфейсе
          СтрокаИдентификатор,  //идентификатор команды; любая строка, уникальная в пределах данной обработки
          "ОткрытиеФормы");
		  
  Возврат ПараметрыРегистрации;
КонецФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование, ПоказыватьОповещение = Ложь, Модификатор = "")

  НоваяКоманда = ТаблицаКоманд.Добавить();
  НоваяКоманда.Представление = Представление;
  НоваяКоманда.Идентификатор = Идентификатор;
  НоваяКоманда.Использование = Использование;
  НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
  НоваяКоманда.Модификатор = Модификатор;

КонецПроцедуры

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыВыполненияКоманды = Неопределено) Экспорт
  // Реализация логики команды
  Если ИдентификаторКоманды = ЭтотОбъект.Метаданные().ПолноеИмя() Тогда
	  
	  ПолучитьТекущиеКурсыВалют();
	  
  КонецЕсли;
  
КонецПроцедуры

#КонецОбласти 
	
#КонецЕсли