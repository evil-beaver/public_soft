﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область Регистрация 

Функция СведенияОВнешнейОбработке() Экспорт
	
  Разрешение = РаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса("HTTPS","api.monobank.ua",443);	
    
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

  СтрокаНастройки = НСтр("ru = настройка'; uk = 'налаштування';");
  
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
	  
	   ВыполнитьАвтоматическуюЗагрузкуПлатежейИзМонобанка();
	  
  КонецЕсли;
  
КонецПроцедуры

#КонецОбласти 
	

#Область ТехническиеПроцедурыФункции

Функция ПолучитьДатуИзСтроки(TimeUNIX) 
	
	ЧасовойПояс = ПолучитьЧасовойПоясИнформационнойБазы();
	
	СмещениеДаты = СмещениеСтандартногоВремени(ЧасовойПояс);
	
	Возврат Дата(1970,1,1,1,0,0) + TimeUNIX + СмещениеДаты; 
		 
КонецФункции

Функция ПолучитьСоединениеСМонобанком()

	SSL = Новый ЗащищенноеСоединениеOpenSSL;
	HTTPСоединение = Новый HTTPСоединение("api.monobank.ua",,,,,,SSL);
	
	Возврат HTTPСоединение
	
КонецФункции // ПолучитьСоединениеСМонобанком()

Функция ПолучитьЗапросПолученияПлатежейКМонобанку(Токен,ИДСчета,ДатаНачалаЮникс,ДатаОкончанияЮникс)
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("X-Token", Токен); 
	
	РесурсНаСервере = "/personal/statement/" + ИДСчета + "/" + ДатаНачалаЮникс + "/" + ДатаОкончанияЮникс;
	
	HTTPЗапрос = Новый HTTPЗапрос(РесурсНаСервере, Заголовки);
	
	Возврат HTTPЗапрос	

КонецФункции // ПолучитьЗапросКМонобанку()

Функция ПолучитьЗапросПолученияПерсональнойИнформации(Токен)

	Заголовки = Новый Соответствие;
	Заголовки.Вставить("X-Token", Токен); 
	
	РесурсНаСервере = "/personal/client-info";
	
	HTTPЗапрос = Новый HTTPЗапрос(РесурсНаСервере, Заголовки);
	
	Возврат HTTPЗапрос	
	
КонецФункции // ПолучитьЗапросПолученияПерсональнойИнформации()

Функция ПолучитьДатуTimeUNIX(Знач Дата)
	
	ДатаНачалаЮникс = Дата(1970,1,1,1,0,0);
	
	ДатаЮникс = Формат(Дата - ДатаНачалаЮникс, "ЧГ=0");
	
	Возврат ДатаЮникс
	
КонецФункции // ПолучитьДату()

Процедура ВыполнитьВостановлениеСохраненныхДанны()
	
	НастройкиЗагрузки = ХранилищеОбщихНастроек.Загрузить("НастройкиЗагрузкиМоно","НастройкиЗагрузкиМоно","НастройкиЗагрузкиМоно");
	
	Если Не НастройкиЗагрузки = Неопределено Тогда
	
		СоответствиеСчетовБанка.Загрузить(НастройкиЗагрузки.Получить("ТаблицаСчетов"));
		СвойствоИдентификаторПлатежа = НастройкиЗагрузки.получить("СвойствоИдентификаторПлатежа");
		СтатьяДвиженияДенежныхСредствПоставщик = НастройкиЗагрузки.получить("СтатьяДвиженияДенежныхСредствПоставщик");
		СтатьяДвиженияДенежныхСредствПокупатель = НастройкиЗагрузки.получить("СтатьяДвиженияДенежныхСредствПокупатель"); 
		КонтрагентПокупательПоУмолчанию = НастройкиЗагрузки.получить("КонтрагентПокупательПоУмолчанию");
		КонтрагентПоставщикПоУмолчанию = НастройкиЗагрузки.получить("КонтрагентПоставщикПоУмолчанию");


	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьСмещениеДатыЮникс()

	ЧасовойПоясСеанса = ЧасовойПоясСеанса();

	СмещениеОтСтандартногоВремени = СмещениеСтандартногоВремени(ЧасовойПоясСеанса);

	СмещениеЛетнегоВремени = СмещениеЛетнегоВремени(ЧасовойПоясСеанса);

	ОбщееСмещениеВремени = СмещениеОтСтандартногоВремени + СмещениеЛетнегоВремени;

	Возврат ОбщееСмещениеВремени

КонецФункции // ПолучитьСмещениеДатыЮникс()

#КонецОбласти 

#Область ОбработчикиЗагрузкиПлатежей

Процедура ВыполнитьАвтоматическуюЗагрузкуПлатежейИзМонобанка()Экспорт

   ВыполнитьВостановлениеСохраненныхДанны();	
   
   ДатаОкончанияЗагрузки = ТекущаяДатаСеанса();
      
   ДатаНачалаЗагрузки    = ДобавитьМесяц(ДатаОкончанияЗагрузки, -1);
   
   Пауза = 60;
   
   Для каждого СтрокаЗагрузки Из СоответствиеСчетовБанка Цикл
	   
	    Если Не ЗначениеЗаполнено(СтрокаЗагрузки.БанковскийСчетКасса) Тогда
		
			 Продолжить;
		
		КонецЕсли;
	   
   	    ВыполнитьЗагрузкуПоСчетуКассе(СтрокаЗагрузки,ДатаНачалаЗагрузки,ДатаОкончанияЗагрузки);
		
		ДатаЗапуска = ТекущаяДатаСеанса()+ Пауза;
		
		Пока ДатаЗапуска > ТекущаяДатаСеанса()Цикл КонецЦикла;
		
   КонецЦикла;
   
КонецПроцедуры

Процедура ВыполнитьЗагрузкуПоСчетуКассе(СтрокаНастроек,ДатаНачалаЗагрузки,ДатаОкончанияЗагрузки)
	 
	Токен    = СтрокаНастроек.АпиКлюч;
	
	ИДСчета  = СтрокаНастроек.Идентификатор;
	
	ДатаОкончанияЮникс = ПолучитьДатуTimeUNIX(ДатаОкончанияЗагрузки);

	Если ДатаНачалаЗагрузки <= СтрокаНастроек.ДатаНачалаОбмена Тогда
	
		 ДатаНачалаЗагрузки = СтрокаНастроек.ДатаНачалаОбмена;
	
	КонецЕсли; 
	
	ДатаНачалаЮникс = ПолучитьДатуTimeUNIX(ДатаНачалаЗагрузки);
	
	HTTPСоединение = ПолучитьСоединениеСМонобанком();
	
	HTTPЗапрос    = ПолучитьЗапросПолученияПлатежейКМонобанку(Токен,ИДСчета,ДатаНачалаЮникс,ДатаОкончанияЮникс);
	
	Результат = HTTPСоединение.Получить(HTTPЗапрос);
	
	HTTPСоединение = Неопределено;
	
	ТекстВозрата = Результат.ПолучитьТелоКакСтроку();
	
	Попытка 
		ЧтениеJson = Новый ЧтениеJSON;
		ЧтениеJson.УстановитьСтроку(ТекстВозрата);			
		Данные = ПрочитатьJSON(ЧтениеJson,Ложь,,ФорматДатыJSON.ISO);
	Исключение
		ЗаписьЖурналаРегистрации("Загрузка платежей из Монобанка",,,,ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат;
	КонецПопытки;
	
	Если ТипЗнч(Данные) = Тип("Структура") Тогда 
		Если Данные.Свойство("errorDescription") Тогда
			ЗаписьЖурналаРегистрации("Загрузка платежей из Монобанка",,,,Нстр("ru = 'Ошибка при получении платежей '; uk = 'Помилка при отриманні даних '") + Данные.errorDescription);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	ОбработатьДанныеБанка(Данные,СтрокаНастроек.Организация,СтрокаНастроек.Валюта,СтрокаНастроек.БанковскийСчетКасса);
		
КонецПроцедуры

Функция ПолучитьОбъектПоСвойствуИзначению(Значение,ТипДанных,СуммаПлатежа)Экспорт
	
	Если Не ЗначениеЗаполнено(СвойствоИдентификаторПлатежа) Тогда
	
		ВызватьИсключение(НСтр("ru = 'Не указано свойство идентификатор платежей выгрузка прервана!'; uk = 'Не вказано властивість ідентифікатор платежів перервано вивантаження!';"));	
	
	КонецЕсли;
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	ДополнительныеСведения.Объект КАК ДокументСсылка
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
	|ГДЕ
	|	ДополнительныеСведения.Объект ССЫЛКА Документ.ТипДокумента
	|	И ДополнительныеСведения.Значение = &Значение
	|	И ДополнительныеСведения.Свойство = &Свойство
	|	И Выразить(ДополнительныеСведения.Объект как Документ.ТипДокумента).СуммаДокумента = &СуммаПлатежа");
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст,"ТипДокумента",ТипДанных);
	
	Запрос.УстановитьПараметр("Свойство",СвойствоИдентификаторПлатежа);
	Запрос.УстановитьПараметр("Значение",Значение);
	Запрос.УстановитьПараметр("СуммаПлатежа",СуммаПлатежа);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	ЕстьДокументВБазе = Ложь;
	
	Если Выборка.Следующий() 
		И ЗначениеЗаполнено(Выборка.ДокументСсылка) Тогда
	
		ЕстьДокументВБазе = Истина;
	
	КонецЕсли;
	
	Возврат ЕстьДокументВБазе

КонецФункции

#Область РаботаСДокументами

Процедура ОбработатьДанныеБанка(Данные,Организация,Валюта,КассаБанкСчет)
	
	Для Каждого Платеж Из Данные Цикл
				
		Попытка
		
			СуммаПлатежа = Число(Платеж.amount) / 100;			
		
		Исключение
			
			ЗаписьЖурналаРегистрации("Загрузка платежей из системы монобанк", , Метаданные.РегламентныеЗадания.jan_ЗагрузкаПлатежейИзСистемыПриват24, , НСтр("ru = 'Не удалось преобразовать сумму платежа в число. Сумма: ';uk='Не вдалося перетворити суму платежу в число. Сума: '") + Данные.amount);
			Продолжить;
			
		КонецПопытки;
		
		ТипПроводки = "D";
		
		ЭтоРасход = СуммаПлатежа <= 0;
		
		Если  ЭтоРасход Тогда
		
			  ТипПроводки 	= "C";
		      СуммаПлатежа  = -СуммаПлатежа;
			  
		КонецЕсли; 
		
		ТипДокумента = "";
		
		Если  ТипПроводки 	= "C" 
			И ТипЗнч(КассаБанкСчет) = Тип("СправочникСсылка.Кассы") Тогда
			
			ТипДокумента = "РасходИзКассы";
		
		КонецЕсли;	
			
		Если  ТипПроводки 	= "D" 
			И ТипЗнч(КассаБанкСчет) = Тип("СправочникСсылка.Кассы") Тогда
			
			ТипДокумента = "ПоступлениеВКассу";
		
		КонецЕсли;
			
		Если  ТипПроводки 	= "D" 
			И ТипЗнч(КассаБанкСчет) = Тип("СправочникСсылка.БанковскиеСчета") Тогда	
			
			ТипДокумента = "ПоступлениеНаСчет";
		
		КонецЕсли;

		Если  ТипПроводки 	= "C" 
			И ТипЗнч(КассаБанкСчет) = Тип("СправочникСсылка.БанковскиеСчета") Тогда		
			
			ТипДокумента = "РасходСоСчета";
			
		КонецЕсли;
		
		Если ПолучитьОбъектПоСвойствуИзначению(Платеж.id,ТипДокумента,СуммаПлатежа) Тогда
			Продолжить;
		КонецЕсли;
		
		СоздатьДокументКассыБанка (Платеж,КассаБанкСчет,Организация,Валюта,СуммаПлатежа,ТипДокумента);
		
	КонецЦикла;
	

КонецПроцедуры

Процедура СоздатьДокументКассыБанка (СоответствиеБанка,БанкКасса,Организация,Валюта,СуммаПлатежа,ТипДокумента)
	

	ДокументОбъект 					 = Документы[ТипДокумента].СоздатьДокумент();
	ДокументОбъект.Автор			 = Пользователи.ТекущийПользователь();
	ДокументОбъект.дата  			 = ПолучитьДатуИзСтроки(СоответствиеБанка.Time);
	ДокументОбъект.Организация       = Организация;
	ДокументОбъект.СуммаДокумента	 = СуммаПлатежа;
		
	КодЕдрпо = "";
	
	Если СоответствиеБанка.Свойство("counterEdrpou")Тогда
		
		КонтрагентПоКодЕдрпоу							= Справочники.Контрагенты.НайтиПоРеквизиту("КодПоЕДРПОУ",СокрЛП(СоответствиеБанка.counterEdrpou));
			 		
		Если ЗначениеЗаполнено(КонтрагентПоКодЕдрпоу) Тогда
			
			ДокументОбъект.Контрагент               	= КонтрагентПоКодЕдрпоу;
			
		КонецЕсли;
		
		КодЕдрпо = СоответствиеБанка.counterEdrpou;
		
	КонецЕсли; 
	
	Если Не ЗначениеЗаполнено(ДокументОбъект.Контрагент) Тогда
			
		ДокументОбъект.Контрагент = КонтрагентПокупательПоУмолчанию;
			
	КонецЕсли;
	
	ДокументОбъект.ВалютаДенежныхСредств = Валюта;
	
	ШаблонСтрокиНазначения							= "[%1 ]/[%2/%3]";
	СтрокаНазначения								= СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСтрокиНазначения,
													  СоответствиеБанка.description,
													  ?(СоответствиеБанка.Свойство("comment"),СоответствиеБанка.comment,""),
													  КодЕдрпо);
			
	Если ТипДокумента = "РасходИзКассы" ИЛИ  ТипДокумента = "ПоступлениеВКассу" Тогда
		
		ЗаполнитьКассовыйДокумент(ДокументОбъект,ТипДокумента,БанкКасса,СуммаПлатежа,СтрокаНазначения);
		
	ИначеЕсли ТипДокумента = "РасходСоСчета" ИЛИ  ТипДокумента = "ПоступлениеНаСчет" Тогда
		
		ЗаполнитьДокументБанка(ДокументОбъект,ТипДокумента,БанкКасса,СуммаПлатежа,СтрокаНазначения);
		
	КонецЕсли;	
		
	ДокументОбъект.Комментарий = СтрокаНазначения; 
	
	СтрокаДопРеквизит = ДокументОбъект.ДополнительныеРеквизиты.Добавить();
	СтрокаДопРеквизит.Свойство = СвойствоИдентификаторПлатежа;
	СтрокаДопРеквизит.Значение = СоответствиеБанка.id;
	СтрокаДопРеквизит.ТекстоваяСтрока = СоответствиеБанка.id; 
	
	ДокументОбъект.Записать(РежимЗаписиДокумента.Запись);
	
	ЗафиксироватьСвойствоДокумента(ДокументОбъект.Ссылка,СоответствиеБанка.id);
	   												 
КонецПроцедуры

Процедура ЗаполнитьКассовыйДокумент(ДокументОбъект,ТипДокумента,БанкКасса,СуммаПлатежа,СтрокаНазначения)
	
	СписокДоговоров = Новый СписокЗначений;
	
	ДокументОбъект.Касса				     = БанкКасса;
	ДокументОбъект.Основание				 = СтрокаНазначения;	
			
	СтрокаРасшифровки = ДокументОбъект.РасшифровкаПлатежа.Добавить();
	
	Если ТипДокумента = "РасходИзКассы" Тогда

		ДокументОбъект.ВидОперации	= Перечисления.ВидыОперацийРасходИзКассы.Поставщику;
					
	ИначеЕсли ТипДокумента = "ПоступлениеВКассу"  Тогда 	
		
		ДокументОбъект.ВидОперации			 = Перечисления.ВидыОперацийПоступлениеВКассу.ОтПокупателя;
				
	КонецЕсли;
		
	ЗаполнитьОбщиеДанныеДокументов(ДокументОбъект,СтрокаРасшифровки,СписокДоговоров,ТипДокумента,СуммаПлатежа);
		  
КонецПроцедуры

Процедура ЗаполнитьДокументБанка(ДокументОбъект,ТипДокумента,БанкКасса,СуммаПлатежа,СтрокаНазначения)
	
	СписокДоговоров = Новый СписокЗначений;
	
	ДокументОбъект.БанковскийСчет		     = БанкКасса;
	ДокументОбъект.НазначениеПлатежа		 = СтрокаНазначения;
	
	СтрокаРасшифровки = ДокументОбъект.РасшифровкаПлатежа.Добавить();
	
	Если ТипДокумента = "РасходСоСчета" Тогда
		
		ДокументОбъект.ВидОперации	= Перечисления.ВидыОперацийРасходСоСчета.Поставщику;
				
		Если Не ЗначениеЗаполнено(ДокументОбъект.Контрагент) Тогда
			
			ДокументОбъект.Контрагент = КонтрагентПоставщикПоУмолчанию;
			
		КонецЕсли;
		
	ИначеЕсли ТипДокумента = "ПоступлениеНаСчет"  Тогда 	
		
		ДокументОбъект.ВидОперации			 = Перечисления.ВидыОперацийПоступлениеНаСчет.ОтПокупателя;
		
	КонецЕсли;
	
	ЗаполнитьОбщиеДанныеДокументов(ДокументОбъект,СтрокаРасшифровки,СписокДоговоров,ТипДокумента,СуммаПлатежа);	

КонецПроцедуры

Процедура ЗаполнитьОбщиеДанныеДокументов(ДокументОбъект,СтрокаРасшифровки,СписокДоговоров,ТипДокумента,СуммаПлатежа)
	
	Если ТипДокумента = "РасходИзКассы" Тогда
		
		СписокДоговоров.Добавить(Перечисления.ВидыДоговоров.СПоставщиком);
		ДокументОбъект.Статья      = СтатьяДвиженияДенежныхСредствПоставщик;
		
		Если Не ЗначениеЗаполнено(ДокументОбъект.Контрагент) Тогда
			
			ДокументОбъект.Контрагент = КонтрагентПоставщикПоУмолчанию;
			
		КонецЕсли;
		
	ИначеЕсли ТипДокумента = "ПоступлениеВКассу" 
		Или ТипДокумента = "ПоступлениеНаСчет"   Тогда 	
		
		СписокДоговоров.Добавить(Перечисления.ВидыДоговоров.СПокупателем);
		ДокументОбъект.ХозяйственнаяОперация = Справочники.ХозяйственныеОперации.ПоступлениеОплатыОтПокупателя;
		СтрокаРасшифровки.СтатьяДекларацииПоЕдиномуНалогу = Справочники.СтатьиНалоговыхДеклараций.ЕННК_ДоходыРеализация;
		
		ДокументОбъект.Статья      = СтатьяДвиженияДенежныхСредствПокупатель;
				
	КонецЕсли;

	
	СтрокаРасшифровки.Договор = ПолучитьДоговорПоУмолчанию(ДокументОбъект,СписокДоговоров,ДокументОбъект.ВалютаДенежныхСредств);
	
	СтруктураКурсов 			= РаботаСКурсамиВалют.ПолучитьКурсВалюты(ДокументОбъект.ВалютаДенежныхСредств,ДокументОбъект.Дата);
	
	СтрокаРасшифровки.Кратность 		= СтруктураКурсов.Кратность;
	СтрокаРасшифровки.Курс		 		= СтруктураКурсов.Курс;
	СтрокаРасшифровки.СуммаПлатежа     	= СуммаПлатежа;
	СтрокаРасшифровки.СуммаРасчетов    	= СуммаПлатежа;

	
	ДокументОбъект.НалогообложениеНДС  	= НалогиУНФ.НалогообложениеНДС(ДокументОбъект.Организация,, ДокументОбъект.Дата);
	
	СтрокаРасшифровки.СтавкаНДС	 		= получитьСтавкуНдсПоУмолчанию(ДокументОбъект.НалогообложениеНДС,ДокументОбъект.Организация);
	
КонецПроцедуры

Функция получитьСтавкуНдсПоУмолчанию(НалогообложениеНДС,Организация)

	Если НалогообложениеНДС = Перечисления.ТипыНалогообложенияНДС.ОблагаетсяНДС Тогда
		СтавкаНДСПоУмолчанию = Справочники.СтавкиНДС.СтавкаНДС(Организация.ВидСтавкиНДСПоУмолчанию);
	ИначеЕсли НалогообложениеНДС = Перечисления.ТипыНалогообложенияНДС.НеОблагаетсяНДС Тогда
		СтавкаНДСПоУмолчанию = УправлениеНебольшойФирмойПовтИсп.ПолучитьСтавкуНДСБезНДС();
	Иначе
		СтавкаНДСПоУмолчанию = УправлениеНебольшойФирмойПовтИсп.ПолучитьСтавкуНДСНоль();
	КонецЕсли;
		
	Возврат СтавкаНДСПоУмолчанию;

КонецФункции // получитьСтавкуНдсПоУмолчанию()

Функция ПолучитьДоговорПоУмолчанию(ДокументОбъект,СписокДоговоров,Валюта)
	
	МенеджерСправочника = Справочники.ДоговорыКонтрагентов; 
	
	ДоговорПоУмолчанию = МенеджерСправочника.ПолучитьДоговорПоУмолчаниюПоОрганизацииВидуДоговора(ДокументОбъект.Контрагент,
																								 ДокументОбъект.Организация,
																								 СписокДоговоров,Валюта);
	Возврат ДоговорПоУмолчанию


КонецФункции // ПолучитьДоговорПоУмолчанию()

Процедура ЗафиксироватьСвойствоДокумента(ДокументСсылка,ЗначениеСвойства)
	
	МенеджерСвойства = РегистрыСведений.ДополнительныеСведения.СоздатьМенеджерЗаписи();
	МенеджерСвойства.Свойство = СвойствоИдентификаторПлатежа;
	МенеджерСвойства.Значение = ЗначениеСвойства;
	МенеджерСвойства.Объект   = ДокументСсылка;
	МенеджерСвойства.Записать();	

КонецПроцедуры

#КонецОбласти 

#КонецОбласти 

#Область ПолучениеСпискаКартСчетовПользователя

Функция ПолучитьСписокБанковскихКартСчетовПользователя(ТокенМонобанк)Экспорт

	ТаблицаСчетовКарт = Новый ТаблицаЗначений;
	ДлинаСтроки = 150;
	описаниеТипаСтрока = Новый описаниеТипов("Строка",,,,Новый КвалификаторыСтроки(ДлинаСтроки));
	
	ТаблицаСчетовКарт.Колонки.Добавить("ПредставлениеСчетаКарты",описаниеТипаСтрока);
	ТаблицаСчетовКарт.Колонки.Добавить("Идентификатор",описаниеТипаСтрока);
	ТаблицаСчетовКарт.Колонки.Добавить("АпиКлюч",описаниеТипаСтрока);
	ТаблицаСчетовКарт.Колонки.Добавить("Валюта",Новый описаниеТипов("СправочникСсылка.Валюты"));
	
	HTTPСоединение = ПолучитьСоединениеСМонобанком();
	
	HTTPЗапрос     = ПолучитьЗапросПолученияПерсональнойИнформации(ТокенМонобанк);
	
	Результат = HTTPСоединение.Получить(HTTPЗапрос);
	
	HTTPСоединение = Неопределено;
	
	ТекстВозрата = Результат.ПолучитьТелоКакСтроку();
	
	Попытка 
		ЧтениеJson = Новый ЧтениеJSON;
		ЧтениеJson.УстановитьСтроку(ТекстВозрата);			
		Данные = ПрочитатьJSON(ЧтениеJson);
	Исключение
		ЗаписьЖурналаРегистрации("Загрузка платежей из Монобанка.получение персональной информации",,,,ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ВызватьИсключение(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Если ТипЗнч(Данные) = Тип("Структура") Тогда 
		Если Данные.Свойство("errorDescription") Тогда
			ЗаписьЖурналаРегистрации("Загрузка платежей из Монобанка.получение персональной информации",,,,Нстр("ru = 'Ошибка при получении платежей '; uk = 'Ошибка при получении платежей '") + Данные.errorDescription);
			ВызватьИсключение(Данные.errorDescription);
		КонецЕсли;
		
	КонецЕсли;
	
	Для каждого СчетКлиента  Из Данные.accounts  Цикл
		
		НоваяСтрока = ТаблицаСчетовКарт.Добавить();
		
		МаскаСчетаКарты = СчетКлиента.iban;
		
		Если СчетКлиента.maskedPan.количество() Тогда
		
			МаскаСчетаКарты = СчетКлиента.maskedPan.Получить(0);
		
		КонецЕсли;
		
		ПредставлениеСчетаКАрты = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1/%2/%3",СчетКлиента.type,СчетКлиента.currencyCode,МаскаСчетаКарты);
		
		НоваяСтрока.ПредставлениеСчетаКарты	 = ПредставлениеСчетаКАрты;
		НоваяСтрока.Идентификатор			 = СчетКлиента.id;
		НоваяСтрока.АпиКлюч					 = ТокенМонобанк;		
		НоваяСтрока.Валюта					 = Справочники.Валюты.НайтиПоКоду(СчетКлиента.currencyCode);
		
	КонецЦикла;
	
	Возврат ТаблицаСчетовКарт
	
КонецФункции // ПолучитьСписокБанковскихКартСчетовПользователя()
 
#КонецОбласти 

#КонецЕсли	