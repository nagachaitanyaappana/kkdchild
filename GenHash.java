import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
public class GenHash { public static void main(String[] a){ System.out.print(new BCryptPasswordEncoder().encode("admin123")); } }
