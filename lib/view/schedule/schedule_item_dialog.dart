import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String testTxt = """Gleich darauf stellt sie den Eltern beim Elterntag eine Aufgabe: „Es gibt insgesamt 27 Vögel auf drei Bäumen. Von dem ersten Baum fliegen zwei auf den zweiten Baum, von dem zweiten Baum fliegen drei auf den dritten Baum. Dann fliegen vier Vögel vom dritten Baum auf den ersten Baum. Nun gibt es auf den drei Bäumen jeweils die gleiche Anzahl von Vögeln. Die Frage lautet, wie viele Vögel gab es ursprünglich auf den Bäumen?“

Der Ansporn sinkt, wenn im Kindergarten schon zu viel vermittelt wird
Während einige Eltern eifrig zu rechnen beginnen, breitet sich auf den Gesichtern anderer Panik aus. Alle wissen, dass sie nun anfangen müssen, mit ihren Kindern zu üben. Ihre Kinder lernen zwar, laut der neuen Vorgaben der Behörden, seit ein paar Jahren nicht mehr Mathematik im traditionellen Sinne, doch sie bekommen ein Gefühl für Zahlen vermittelt. Und das beginnt schon im Alter von vier Jahren im Kindergarten.

„Man habe gemerkt, dass Kinder, denen schon im Kindergarten alles beigebracht wird, in der Schule keinen Ansporn mehr haben, zu lernen. Früher war es so, dass die Kinder schon alles konnten, was ihnen laut Lehrplan in der ersten und zweiten Klasse beigebracht werden sollte“, sagt Frau Chen und mahnt die Eltern, es mit der vorschulischen Ausbildung nicht zu übertreiben.


Denn häufig schicken Eltern ihre Kinder schon mit Kindergarteneintritt zum Mathematikunterricht. Wenn die Kinder in die erste Klasse kommen, können sie den Stoff bis einschließlich der zweiten Klasse.

Schulische Leistungen gelten als Voraussetzung für den sozialen Aufstieg
Bildung gilt Eltern in asiatischen Ländern und besonders in China als Voraussetzung und Garant für sozialen Aufstieg und eine solide Karriere ihrer Kinder. „Chiku“ – frei übersetzt „leiden“ – gehört dazu. Nur durch harte Arbeit kann man alles erreichen.

Das ist die chinesische Variante des amerikanischen Traums „vom Tellerwäscher zum Millionär“. Allerdings geht es nicht nach der Vorstellung des Selfmade-Millionärs. Die Mühen, die es zu bewältigen gilt, beziehen sich auf die schulischen und akademischen Leistungen. Nur dann hat man Aussicht auf einen guten Job und ein gutes Einkommen.

Lange galt das Bildungssystem als starr, mit zu viel Frontalunterricht, bei dem die Lehrer ihren Stoff runterreißen und kaum auf das Lerntempo der Schüler eingehen können. Freizeit kennen die Kinder kaum. Spiel und Spaß kommen nach westlicher Sichtweise viel zu kurz.

Auch wenn im Kindergarten behutsam umgesteuert wird, hat sich insgesamt wenig geändert. So zeigt eine aktuelle OECD-Studie, dass Chinas Schüler in Sachen Mathematik, Naturwissenschaften und Lesen weltweit am besten abgeschnitten haben. Mit Peking und Shanghai sowie den Provinzen Zhejiang und Jiangsu hat China in der aktuellen Pisa-Studie überall die Spitzenplätze weltweit belegt.

Einen Großteil der Hausaufgaben macht Mathematik aus
Das aktuelle Curriculum des Bildungsministeriums für die Primarstufe sieht für die erste Klasse pro Woche vier Stunden Mathematikunterricht vor. Das klingt erst mal nicht viel. Aber nicht nur die Herangehensweise ist unterschiedlich, auch die Komplexität und die Zeit, die für Matheaufgaben aufgewendet wird, unterscheiden sich vom Westen.""";

void showScheduleItemDialog(BuildContext context, ScheduleItem scheduleItem) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (buildContext)
  {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            Padding(
            padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
            child: Text(
              scheduleItem.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
              child: SingleChildScrollView(
                child: Text("blabla"),
              ),
//              child: ListView(
//                children: <Widget>[
//                  scheduleItem.venue != null && scheduleItem.venue.isNotEmpty ? Row(
//                    children: <Widget>[
//                      Icon(Icons.place),
//                      Text(scheduleItem.venue)
//                    ],
//                  ) : Container(),
//                  scheduleItem.speaker != null && scheduleItem.speaker.isNotEmpty ? Row(
//                    children: <Widget>[
//                      Icon(Icons.person),
//                      Text(scheduleItem.speaker)
//                    ],
//                  ) : Container(),
//                  Text("blabla"),
//                ],
//              ),
            ),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: (){},
                child: Text("PUSH ME"),
              )
            ],
          )
        ],
      ),
    );
  });
//    return AlertDialog(
//      title: Align(
//        alignment: Alignment.centerLeft,
//        child: Text(
//          scheduleItem.title,
//          style: TextStyle(
//            fontSize: 24.0,
//            fontWeight: FontWeight.w300,
//          ),
//        ),
//      ),
//      content: SingleChildScrollView(
//        child: Column(
//          children: <Widget>[
//            Text("""Gleich darauf stellt sie den Eltern beim Elterntag eine Aufgabe: „Es gibt insgesamt 27 Vögel auf drei Bäumen. Von dem ersten Baum fliegen zwei auf den zweiten Baum, von dem zweiten Baum fliegen drei auf den dritten Baum. Dann fliegen vier Vögel vom dritten Baum auf den ersten Baum. Nun gibt es auf den drei Bäumen jeweils die gleiche Anzahl von Vögeln. Die Frage lautet, wie viele Vögel gab es ursprünglich auf den Bäumen?“
//
//Der Ansporn sinkt, wenn im Kindergarten schon zu viel vermittelt wird
//Während einige Eltern eifrig zu rechnen beginnen, breitet sich auf den Gesichtern anderer Panik aus. Alle wissen, dass sie nun anfangen müssen, mit ihren Kindern zu üben. Ihre Kinder lernen zwar, laut der neuen Vorgaben der Behörden, seit ein paar Jahren nicht mehr Mathematik im traditionellen Sinne, doch sie bekommen ein Gefühl für Zahlen vermittelt. Und das beginnt schon im Alter von vier Jahren im Kindergarten.
//
//„Man habe gemerkt, dass Kinder, denen schon im Kindergarten alles beigebracht wird, in der Schule keinen Ansporn mehr haben, zu lernen. Früher war es so, dass die Kinder schon alles konnten, was ihnen laut Lehrplan in der ersten und zweiten Klasse beigebracht werden sollte“, sagt Frau Chen und mahnt die Eltern, es mit der vorschulischen Ausbildung nicht zu übertreiben.
//
//
//Denn häufig schicken Eltern ihre Kinder schon mit Kindergarteneintritt zum Mathematikunterricht. Wenn die Kinder in die erste Klasse kommen, können sie den Stoff bis einschließlich der zweiten Klasse.
//
//Schulische Leistungen gelten als Voraussetzung für den sozialen Aufstieg
//Bildung gilt Eltern in asiatischen Ländern und besonders in China als Voraussetzung und Garant für sozialen Aufstieg und eine solide Karriere ihrer Kinder. „Chiku“ – frei übersetzt „leiden“ – gehört dazu. Nur durch harte Arbeit kann man alles erreichen.
//
//Das ist die chinesische Variante des amerikanischen Traums „vom Tellerwäscher zum Millionär“. Allerdings geht es nicht nach der Vorstellung des Selfmade-Millionärs. Die Mühen, die es zu bewältigen gilt, beziehen sich auf die schulischen und akademischen Leistungen. Nur dann hat man Aussicht auf einen guten Job und ein gutes Einkommen.
//
//Lange galt das Bildungssystem als starr, mit zu viel Frontalunterricht, bei dem die Lehrer ihren Stoff runterreißen und kaum auf das Lerntempo der Schüler eingehen können. Freizeit kennen die Kinder kaum. Spiel und Spaß kommen nach westlicher Sichtweise viel zu kurz.
//
//Auch wenn im Kindergarten behutsam umgesteuert wird, hat sich insgesamt wenig geändert. So zeigt eine aktuelle OECD-Studie, dass Chinas Schüler in Sachen Mathematik, Naturwissenschaften und Lesen weltweit am besten abgeschnitten haben. Mit Peking und Shanghai sowie den Provinzen Zhejiang und Jiangsu hat China in der aktuellen Pisa-Studie überall die Spitzenplätze weltweit belegt.
//
//Einen Großteil der Hausaufgaben macht Mathematik aus
//Das aktuelle Curriculum des Bildungsministeriums für die Primarstufe sieht für die erste Klasse pro Woche vier Stunden Mathematikunterricht vor. Das klingt erst mal nicht viel. Aber nicht nur die Herangehensweise ist unterschiedlich, auch die Komplexität und die Zeit, die für Matheaufgaben aufgewendet wird, unterscheiden sich vom Westen."""),
//          ],
//        ),
//      ),
//    );
//  });
//        return Dialog(
//          child: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Padding(
//                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 24.0, right: 24.0),
//                child: Align(
//                  alignment: Alignment.centerLeft,
//                  child: Text(
//                    scheduleItem.title,
//                    style: TextStyle(
//                      fontSize: 24.0,
//                      fontWeight: FontWeight.w300,
//                    ),
//                  ),
//                ),
//              ),
//              Divider(
//                color: Colors.black.withOpacity(0.2),
//                thickness: 0.2,
//              ),
//              SingleChildScrollView(
//                child: Text("""Gleich darauf stellt sie den Eltern beim Elterntag eine Aufgabe: „Es gibt insgesamt 27 Vögel auf drei Bäumen. Von dem ersten Baum fliegen zwei auf den zweiten Baum, von dem zweiten Baum fliegen drei auf den dritten Baum. Dann fliegen vier Vögel vom dritten Baum auf den ersten Baum. Nun gibt es auf den drei Bäumen jeweils die gleiche Anzahl von Vögeln. Die Frage lautet, wie viele Vögel gab es ursprünglich auf den Bäumen?“
//
//Der Ansporn sinkt, wenn im Kindergarten schon zu viel vermittelt wird
//Während einige Eltern eifrig zu rechnen beginnen, breitet sich auf den Gesichtern anderer Panik aus. Alle wissen, dass sie nun anfangen müssen, mit ihren Kindern zu üben. Ihre Kinder lernen zwar, laut der neuen Vorgaben der Behörden, seit ein paar Jahren nicht mehr Mathematik im traditionellen Sinne, doch sie bekommen ein Gefühl für Zahlen vermittelt. Und das beginnt schon im Alter von vier Jahren im Kindergarten.
//
//„Man habe gemerkt, dass Kinder, denen schon im Kindergarten alles beigebracht wird, in der Schule keinen Ansporn mehr haben, zu lernen. Früher war es so, dass die Kinder schon alles konnten, was ihnen laut Lehrplan in der ersten und zweiten Klasse beigebracht werden sollte“, sagt Frau Chen und mahnt die Eltern, es mit der vorschulischen Ausbildung nicht zu übertreiben.
//
//
//Denn häufig schicken Eltern ihre Kinder schon mit Kindergarteneintritt zum Mathematikunterricht. Wenn die Kinder in die erste Klasse kommen, können sie den Stoff bis einschließlich der zweiten Klasse.
//
//Schulische Leistungen gelten als Voraussetzung für den sozialen Aufstieg
//Bildung gilt Eltern in asiatischen Ländern und besonders in China als Voraussetzung und Garant für sozialen Aufstieg und eine solide Karriere ihrer Kinder. „Chiku“ – frei übersetzt „leiden“ – gehört dazu. Nur durch harte Arbeit kann man alles erreichen.
//
//Das ist die chinesische Variante des amerikanischen Traums „vom Tellerwäscher zum Millionär“. Allerdings geht es nicht nach der Vorstellung des Selfmade-Millionärs. Die Mühen, die es zu bewältigen gilt, beziehen sich auf die schulischen und akademischen Leistungen. Nur dann hat man Aussicht auf einen guten Job und ein gutes Einkommen.
//
//Lange galt das Bildungssystem als starr, mit zu viel Frontalunterricht, bei dem die Lehrer ihren Stoff runterreißen und kaum auf das Lerntempo der Schüler eingehen können. Freizeit kennen die Kinder kaum. Spiel und Spaß kommen nach westlicher Sichtweise viel zu kurz.
//
//Auch wenn im Kindergarten behutsam umgesteuert wird, hat sich insgesamt wenig geändert. So zeigt eine aktuelle OECD-Studie, dass Chinas Schüler in Sachen Mathematik, Naturwissenschaften und Lesen weltweit am besten abgeschnitten haben. Mit Peking und Shanghai sowie den Provinzen Zhejiang und Jiangsu hat China in der aktuellen Pisa-Studie überall die Spitzenplätze weltweit belegt.
//
//Einen Großteil der Hausaufgaben macht Mathematik aus
//Das aktuelle Curriculum des Bildungsministeriums für die Primarstufe sieht für die erste Klasse pro Woche vier Stunden Mathematikunterricht vor. Das klingt erst mal nicht viel. Aber nicht nur die Herangehensweise ist unterschiedlich, auch die Komplexität und die Zeit, die für Matheaufgaben aufgewendet wird, unterscheiden sich vom Westen."""),
//              ),
//            ],
//          )
//        );
//      }
//  );
}