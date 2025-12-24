import 'package:flutter/cupertino.dart';
import 'package:tvc/models/utils.dart';
import 'package:tvc/theme/app_text_styles.dart';

class BlockedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/blocked.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "THE TABLE IS BLOCKED. PLEASE CONTACT THE ADMINISTRATOR.",
                    style: AppTextStyles.blocked(context),
                  ),
                  SizedBox(height: Utils.getHeightSize(context, 20)),
                  Text(
                    "Стол заблокирован. Пожалуйста, свяжитесь с администратором.",
                    style: AppTextStyles.blocked(context),
                  ),
                  SizedBox(height: Utils.getHeightSize(context, 20)),
                  Text(
                    "Masa bloklanıb. Zəhmət olmasa, administratorla əlaqə saxlayın.",
                    style: AppTextStyles.blocked(context),
                  ),
                  SizedBox(height: Utils.getHeightSize(context, 50)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
