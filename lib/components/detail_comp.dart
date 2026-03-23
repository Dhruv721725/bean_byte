import 'package:bean_byte/components/alert_comp.dart';
import 'package:bean_byte/themes/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailComp extends StatefulWidget {
  final IconData  icon;
  final String title;
  Object? value;
  Function(String) onEdit;

  DetailComp({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    required this.onEdit
  });

  @override
  State<DetailComp> createState() => _DetailCompState();
}

class _DetailCompState extends State<DetailComp> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value != null ? widget.value.toString() : ""; 
  }

  void onTap(){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text(widget.title, textAlign: TextAlign.left, style: TextStyle(fontSize: 20),),
        titleTextStyle: TextStyle(
          color: AppTheme.primaryColor
        ),
        content: TextField(
          controller: _controller,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor
              )
            )
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: (){
              setState(() {
                widget.value = _controller.text.trim(); 
              });
              Navigator.pop(context);
              widget.onEdit(_controller.text.trim());
            }, 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("Save"),
            )
          ),
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
              _controller.text = widget.value != null ? widget.value.toString() : "";
            }, 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text("Cancel"),
            )
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.fieldDark.withAlpha(100) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withAlpha(12), 
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),

              ),
              child: Icon(widget.icon,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: 8,),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  )
                ),
                Text(widget.value != null ? widget.value.toString() : "unavailable",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                  )
                ),
              ],
            )),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
            ),
          ],
        ),
      ),
    );
  }
}