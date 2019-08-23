<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

# CacheFastReport (Cache` Intersystems)
<br>
Мне очень нравится FastReport . Этот простой и удобный генератор отчетов, который создали с учетом большинства потребностей разработчиков, желающих использовать готовые компоненты для отчетных средств. И при всей своей простоте, удобстве и малом размере дистрибутива, способен обеспечить должный функционал и скорость работы на практически любом серверном оборудовании (при условии что там установлена Windows OS).

<br>
Что мне не хватало в FastReport - это более плотной поддержки другой технологии, с которой я часто работаю - InterSystems Caché и нового продукта InterSystems IRIS, а конкретно - использование языка InterSystems ObjectScript для описания бизнес-логики.

<br>
Из коробки для доступа к данным FastReport использует ODBC, а для описания бизнес-логики в отчетах используется Pascal. В итоге я написал модуль, который реализует возможность использования мощного генератора отчетов FastReport для разрабтчиков на InterSystems с использованием ObjectScript вместо Pascal и интеграцией со средствами разработки в InterSystems.

<br>
Функциональность модуля InterSystems FastReport:
<br>     1) Использование  ObjectScript для реализации логики;
<br>     2) Поддержка вставок ObjectScript в тексте шаблона аналогично технологии CSP;
<br>     3) Встраивание вызова «Дизайнер отчетов FastReport» в меню CacheStudio;
<br>     4) Хранение шаблона и логики построения отчета в одном ObjectScript классе для удобства поставки  отчета ;
<br>     5) Генерация класса по пользовательскому шаблону(созданному в визуальном редакторе);
<br>     6) Оставить возможность использовать Pascal для реализации внутренней логики;
<br>     7) Удобная поставка модуля на продакшен сервер.
         
<br>Так родился проект CacheFastReport . Программа создает отчет в формате: PDF, DOC, CSV, JPG, HTML. В итоге, если вам нужно быстро создать отчет для клиента, и у вас очень мало времени для выполнения этой задачи, то CacheFastReport - это то, что вам нужно.

<br><h3>Настраиваем среду разработчика</h3>
<br>Проект состоит из одного файла FasteReportPlayer.exe,. который должен быть помещен в каталог "*\Cache\bin\" на сервере Cache’ или IRIS.  Перед началом разработки запустите  и настройте параметры для подключения к серверу. Те параметры, которые вы установите при запуске, будут помещены в настройку , для дальнейшего использования при построении отчетов
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image11.png?raw=true"/>
<br>После запуска графической оболочки необходимо установить
классы проекта. Для этого нажмите кнопку «InstallClass».
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image1.png?raw=true"/>

<br>В базе данных появятся следующие лассы
<br>          %ZFastReport.page.cls
<br>          %ZDelphi.Controller.cls
<br>          %ZFastReport.SourceControl.cls
<br>          %ZFastReport.js.cls

<br>Поскольку имена классов начинаются с «%Z****», они будут видны из любой области имен на сервере.
<br>Далее, чтобы иметь возможность запустить дизайнер отчетов в CacheStudio из контекстного меню, вам необходимо установить систему контроля версий в «Портале управления системой» ( http://localhost:57772/csp/sys/mgr/%25CSP.UI.Portal.SourceControl.zen ). Выберите пространство имен, в котором вы будете работать, и укажите «%ZFastReport.SourceControl» в качестве класса управления версиями. Не забудьте сохранить ваши изменения. Существует также второй способ установки системы контроля версий во всех пространствах имен, для этого вам нужно запустить команду в CacheTerminal:
<pre>do ##class(%ZFastReport.SourceControl).InstallSorceControllAllNameSpace()</pre>

<br>Затем вам нужно перезапустить CacheStudio, если он был открыт.
<br>Установка для разработки готова, давайте посмотрим как делаются отчеты.
<br>Для этого вам нужно:
<br>  1) Запустите CacheStudio;
<br>  2) Создать пустой класс;
<br>  3) Сохранить этот класс;
<br>  4) Нажмите правую кнопку мыши и вызовите конструктор из контекстного меню «Инструменты => Конструктор FastReport» ;
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image9.png?raw=true"/>
<br>5) В открывшемся окне необходимо запустить дизайнер форм, для этого нужно нажать кнопку «ShowDesigner»
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image2.png?raw=true"/>
6) Создать макет будущего отчета.
<br>Для примера давайте создадим простой отчет, который содержит статику - заголовок, который выводит результат метода, и таблицу из базы - например вывод списка текущих процессов в области.
<br>Таким образом, в отчете  будет 2 элемента:
<br>ReportTitle, с информацией о сервере и дате создания отчета.
<br>TfrxMasterData, в который выведем список активных процессов на сервере Cache’ (IRIS). Для получения этого списка из можно воспользоваться SQL запросом: select * from %SYS.ProcessQuery .
<br>Для создания отчета нажмите создать Новый:
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image8.png?raw=true"/>
<br>В шаблоне появится три блока ReportTitle , MasterData,PageFooter
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image6.png?raw=true"/>
<br>В ReportTitle  добавляем элемент Memo c текстом и вставками ObjectScript:
<br>Все элементы ObjectScript помещаются в скобки  #( )# - код внутри скобок должен возвращать значение из системы IRIS (Caché).
<br>Таблица выводится блоком MasterData. Для создания колонок необходимо поместить элементы Memo внутрь области MasterData. При необходимости каждый элемент можно обвести контуром по периметру, чтобы нарисовалась таблица.
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image12.png?raw=true"/>
<br>Если мы хотим выполнить SQL запрос на сервере IRIS или Caché и вывести данные в FastReport, нужно прописать этот SQL в свойстве SQLquery элемента MasterData
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image7.png?raw=true"/>
<br> Если в SQL запросе предполагаются изменяемые параметры, тода запрос должен будет иметь следующий вид:
<br><pre>[NameSpaceUserVar=""]  select * from %SYS.ProcessQuery where NameSpace like '%{NameSpaceUserVar}%'</pre>
<br>В квадратных скобках объявляются имена переменных и значения их по умолчанию ( [NameSpaceUserVar=""] )
<br>В фигурных скобках помещается место в которое будет вставлено значение передаваемого значения. ( NameSpace like '%{NameSpaceUserVar}%')
<br>Объект PageFooter оставляем без изменений, для того, чтобы продемонстрировать работу встроенного языка.
<br>После окончания всех манипуляций с шаблоном. Обязательно сохраните его резервную копию на локальном компьютере. Это убережет вас от сбоев,разрывов связи  и иный проблем которые могут возникнуть при сохранении. И закрываем графический редактор.
<br>
<br>Далее обновим связанный с отчетом класс ObjectScript - мы его вводили в в окне приложения - User.TestFastReport  - для этого надо нажать на кнопку “Save to cls”.  
<br>
<br>В ObjectScript классе отчета появятся следующие элементы:
<br>          ClassMethod  PreReport - запускается перед созданием отчета, инициализирует все статические элементы.
<br>          ClassMethod  PostReport - запускается после завершения создания файла (создания отчета).
<br>          XData Maket - Шаблон макета отчета в формате XML
<br>          Parameter  MaketFile - параметр, в котором вы можете указать расположение файла шаблона на сервере. Если этот параметр пуст, то шаблон загружается из «XData Maket»
<br>          ClassMethod “ MasterDataName”Execute () - метод создает строки таблицы
<br>          ClassMethod “ MasterDataName”Fetch () - метод получения следующей строки таблицы
<br>
<br>  Если параметр или метод уже был создан, то при сохранении шаблона этот элемент будет пропущен и останется без изменений.
<br>
<br>
<br>При компиляции класса в его описание  примеры ObjectScript, которые можно использовать для интеграции отчета в CSP и построения отчета на стороне сервера.
<br><img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image3.png?raw=true"/>
<br>Например, для построения отчета на стороне сервера необходимо запустить команду:
<br>
<pre>if ##class ( User.TestFastReport ). ShowReport ( "C:\FastReport\User.TestFastReport.pdf" ,. Error )=0 {   zw Error   }</pre>
<br> User.TestFastReport-  имя класса отчета
<pre>
Class User.TestWeb Extends %CSP.Page
{
   ClassMethod OnPage() As %Status {
    &html<
     < script type = 'text/javascript' src = ' #( $zcvt ( "%ZFastReport.js" , "O" , "URL" ))# .cls' ></ script >
     < script language = 'javascript' >
       isOkFun = function (res){ try { eval(res); } catch (e) {console.log(res);} console.log(res); }
       ProgrressBarFun = function (){ console.log( 'Create...' ); }
       GerReportFile = function (){
          #server( Demo.FastReport3 .ShowReportWeb( 'pdf' , 'USER' ,isOkFun,ProgrressBarFun ) )# ;
       }
     </ script >
     < button   onclick = 'GerReportFile()' >GerReportFile</ button >
    >
    Quit $$$OK
 }
}
</pre>
<br>Если скомпилировать и открыть класс в браузере можно увидеть следующее:
<img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image5.png?raw=true"/>
<br>Нажмите на единственную кнопку “ GerReportFile ” и после построения отчета он будет загружен через браузер.
<img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image4.png?raw=true"/>
<br>
<br>    А) Проект поддерживает следующие компоненты: TfrxMasterData, TfrxMemoView, TfrxBarcode2DView, TfrxBarCodeView.  Это значит что эти компоненты можно модифицировать из ObjectScript

<br>   Б) Хочу отметить, что компонент TfrxPictureView является статическим, и в этой реализации невозможно редактировать его из ObjectScript .  Другая проблема заключается в том, что если вы поместите изображение размером более 32 КБ, у вас могут возникнуть проблемы с сохранением такого шаблона в классе Cache '.  Если возникает необходимость добавить изображения размером более 32 КБ, такой шаблон необходимо будет сохранить во внешнем файле, а для загрузки его системой необходимо подключиться, чтобы указать путь в параметре созданного класса "Parameter MaketFile; "
<br>
<br>   В) Если вы укажете запрос SQL в свойстве Description компонента TfrxMasterData, то при создании класса появится реализация выполнения запроса в ObjectScript .
<br>
<br>   Г) Добавлена поддержка кода COS для элементов “TfrxMemoView”. В тексте внутри конструкции #()# можно использовать вызовы ObjectScript, которые возвращают ответ, и они будут вставляться в созданный отчет, например “#( $zd(+$h) )#” выполняется на сервере и отобразит в отчете текущую дату.
<br>
<br>

<br>7) После редактирования сохраните резервную копию шаблона на компьютере;
<br>8) Далее необходимо сохранить шаблон отчета в классе Cache’ . Для этого нажмите кнопку “Save to cls”. В этом случае в классе будут созданы шаблон и методы для заполнения элементов.
<img src="https://github.com/MyasnikovIA/CacheFastReport/blob/master/img/image10.png?raw=true"/>

<br>Макет для создания отчета создан,  сохранение в классе и может распространяться  на другие сервера. Для этого необходимо только перенести созданный класс.

<br>Чтобы передать отчет между серверами(Разработчик=>Продакшен), вы должны выгрузить созданный класс отчета на сервере разработки и загрузить его на продакшен сервер. Больше никаких дополнительных файлов не требуется.

<br>Так же нет необходимости разворачивать FastReport сервер на  продакшен сервере . Достаточно положить программу FastReportPlayer.exe в каталог *\iris\bin. или \cache\bin или в доступноое для переменной PATH место ,  настроить параметры подключение, как у разработчика (настроить параметры подключения и классы проекта) .  

<br>Еще хотелось бы отметить что построение каждого нового отчета происходит независимо друг от друга. В связи с этим вы можете одновременно запускать несколько отчетов (сколько позволят ресурсы сервера)  

<br>Если на продакшен версии несколько областей имен тогда запускать построение отчета нужно будет из той области, в которую вы загрузили класс отчета.
<br>
<br>Некоторые нюансы:
<br>В этом продукте используются OLE-компоненты «CacheActiveX.Factory» и «FOVISM.VisMCtrl.1». Существуют ситуации, когда эти компоненты не зарегистрированы в системе. Затем вам необходимо перерегистрировать систему. Для этого запустите «cmd.exe» от имени администратора и выполните команду:
<pre>
    cd /d C:\Program Files (x86)\Common Files\InterSystems\Cache
    regsvr32 CacheActiveX.dll
</pre>
<br>
<br>Данный проект тестировался на следующих продуктах компании Intersystems : Cache’ 2013; Cache`2014; Cache’ 2017;Cache’ 2018; IRIS 2018.1.
<h3>В остальном одна русская поговорка гласит: «Лучше один раз увидеть, чем сто раз услышать».</h3>
<br>Видео, показывающее процесс установки проекта:   https://youtu.be/R-Sy56nZelk
<br>
<!--[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg)](https://www.youtube.com/watch?v=YOUTUBE_VIDEO_ID_HERE)-->

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/R-Sy56nZelk/0.jpg)](https://www.youtube.com/watch?v=R-Sy56nZelk)
<br>Создание отчета из веб-интерфейса (технология CSP):   https://youtu.be/m0zLZ8Ljx7k
<br>[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/m0zLZ8Ljx7k/0.jpg)](https://www.youtube.com/watch?v=m0zLZ8Ljx7k)



