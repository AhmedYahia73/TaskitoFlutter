import os
import re

mapping = {
    'LucideIcons.bell': 'Icons.notifications_none',
    'LucideIcons.trendingUp': 'Icons.trending_up',
    'LucideIcons.checkCircle': 'Icons.check_circle_outline',
    'LucideIcons.listPlus': 'Icons.playlist_add',
    'LucideIcons.shoppingCart': 'Icons.shopping_cart_outlined',
    'LucideIcons.mapPin': 'Icons.location_on_outlined',
    'LucideIcons.alertCircle': 'Icons.error_outline',
    'LucideIcons.phoneCall': 'Icons.phone_outlined',
    'LucideIcons.layoutDashboard': 'Icons.dashboard_outlined',
    'LucideIcons.listTodo': 'Icons.checklist_rtl',
    'LucideIcons.map': 'Icons.map_outlined',
    'LucideIcons.user': 'Icons.person_outline',
    'LucideIcons.plus': 'Icons.add',
    'LucideIcons.search': 'Icons.search',
    'LucideIcons.check': 'Icons.check',
    'LucideIcons.trash2': 'Icons.delete_outline',
    'LucideIcons.alertTriangle': 'Icons.warning_amber_outlined',
    'LucideIcons.clock': 'Icons.access_time',
    'LucideIcons.settings': 'Icons.settings_outlined',
    'LucideIcons.shield': 'Icons.security_outlined',
    'LucideIcons.logOut': 'Icons.logout',
    'LucideIcons.chevronRight': 'Icons.chevron_right',
    'LucideIcons.slidersHorizontal': 'Icons.tune',
    'LucideIcons.calendar': 'Icons.calendar_today',
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove import
    content = re.sub(r"import 'package:lucide_icons/lucide_icons\.dart';\n", "", content)
    
    # Replace icons
    for lucide, material in mapping.items():
        content = content.replace(lucide, material)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

base_dir = r"c:\xampp\htdocs\Wego\taskito\lib\screens"
for root, dirs, files in os.walk(base_dir):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))
print("Icons replaced successfully.")
