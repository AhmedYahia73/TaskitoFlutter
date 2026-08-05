const fs = require('fs');
const path = require('path');

const mapping = {
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
};

function processFile(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');
    
    // Remove import
    content = content.replace(/import 'package:lucide_icons\/lucide_icons\.dart';\r?\n/g, "");
    
    // Replace icons
    for (const [lucide, material] of Object.entries(mapping)) {
        content = content.split(lucide).join(material);
    }
    
    fs.writeFileSync(filepath, content, 'utf8');
}

function walkDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            walkDir(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            processFile(fullPath);
        }
    }
}

const baseDir = path.join(__dirname, 'lib', 'screens');
walkDir(baseDir);
console.log("Icons replaced successfully.");
