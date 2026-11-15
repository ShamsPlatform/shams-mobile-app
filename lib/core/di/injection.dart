import 'package:get_it/get_it.dart';
import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/core/theme/theme_storage.dart';
import 'package:shams_mobile_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shams_mobile_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shams_mobile_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/complete_sign_up_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/get_current_auth_user_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:shams_mobile_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/delete_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chat_by_id_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chat_id_by_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/get_or_create_chat_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/mark_chat_as_read_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_chat_list_changes_usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/usecases/watch_new_messages_usecase.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/conversation_provider.dart';
import 'package:shams_mobile_app/features/maintenance/data/datasources/maintenance_remote_data_source.dart';
import 'package:shams_mobile_app/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:shams_mobile_app/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:shams_mobile_app/features/maintenance/domain/usecases/submit_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/maintenance/presentation/providers/maintenance_request_provider.dart';
import 'package:shams_mobile_app/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:shams_mobile_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:shams_mobile_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:shams_mobile_app/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:shams_mobile_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shams_mobile_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:shams_mobile_app/features/posts/data/repositories/post_repository_impl.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_workshop_posts_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/hide_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_post_like_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/update_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/post_editor_provider.dart';
import 'package:shams_mobile_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shams_mobile_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:shams_mobile_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/workshops/data/datasources/review_remote_data_source.dart';
import 'package:shams_mobile_app/features/workshops/data/datasources/workshop_remote_data_source.dart';
import 'package:shams_mobile_app/features/workshops/data/repositories/review_repository_impl.dart';
import 'package:shams_mobile_app/features/workshops/data/repositories/workshop_repository_impl.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/review_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/create_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_my_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_public_workshops_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/toggle_follow_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/upload_workshop_image_usecase.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/my_workshop_provider.dart';
import 'package:shams_mobile_app/core/config/env.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/add_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/delete_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_workshop_reviews_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshop_reviews_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

/// Initializes application-wide dependencies.
///
/// Must be called after `Supabase.initialize(...)`.
Future<void> initDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  _initCore();
  _initAuth();
  _initProfile();
  _initPosts();
  _initWorkshops();
  _initChat();
  _initMaintenance();
  _initNotifications();
}

void _initCore() {
  sl.registerLazySingleton<FileStorageDataSource>(
    () => FileStorageDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ThemeStorage>(() => ThemeStorage(sl()));
}

void _initAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => CompleteSignUpUseCase(sl(), sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentAuthUserUseCase(sl()));
  sl.registerFactory(
    () => AuthProvider(
      watchAuthState: sl(),
      getCurrentAuthUser: sl(),
      signInWithEmail: sl(),
      signInWithGoogle: sl(),
      completeSignUp: sl(),
      signOut: sl(),
    ),
  );
}

void _initProfile() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl(), sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl(), sl()));
  sl.registerFactory(
    () => ProfileProvider(getMyProfile: sl(), updateProfile: sl()),
  );
}

void _initPosts() {
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(
      sl(),
      sl(),
      useDbNotificationTriggers: Env.useDbNotificationTriggers,
    ),
  );
  sl.registerLazySingleton<PostRepository>(() => PostRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetFeedUseCase(sl(), sl()));
  sl.registerLazySingleton(() => GetWorkshopPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePostUseCase(sl()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl()));
  sl.registerLazySingleton(() => HidePostUseCase(sl()));
  sl.registerLazySingleton(() => TogglePostLikeUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));
  sl.registerLazySingleton(() => ToggleCommentLikeUseCase(sl()));
  sl.registerFactory(
    () => FeedProvider(
      getFeed: sl(),
      toggleLike: sl(),
      addComment: sl(),
      deleteComment: sl(),
      toggleCommentLike: sl(),
      hidePost: sl(),
    ),
  );
  sl.registerFactory(
    () => PostEditorProvider(createPost: sl(), updatePost: sl()),
  );
}

void _initWorkshops() {
  sl.registerLazySingleton<WorkshopRemoteDataSource>(
    () => WorkshopRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WorkshopRepository>(
    () => WorkshopRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetPublicWorkshopsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyWorkshopUseCase(sl(), sl()));
  sl.registerLazySingleton(() => CreateWorkshopUseCase(sl(), sl()));
  sl.registerLazySingleton(() => UpdateWorkshopUseCase(sl()));
  sl.registerLazySingleton(() => UploadWorkshopImageUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFollowUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkshopReviewsUseCase(sl()));
  sl.registerLazySingleton(() => AddReviewUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReviewUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReviewUseCase(sl()));
  sl.registerFactory(
    () => WorkshopsProvider(
      getPublicWorkshops: sl(),
      toggleFollow: sl(),
    ),
  );
  sl.registerFactory(
    () => WorkshopReviewsProvider(
      getWorkshopReviews: sl(),
      addReview: sl(),
      updateReview: sl(),
      deleteReview: sl(),
    ),
  );
  sl.registerFactory(
    () => MyWorkshopProvider(
      getMyWorkshop: sl(),
      getWorkshopPosts: sl(),
      createWorkshop: sl(),
      updateWorkshop: sl(),
      uploadWorkshopImage: sl(),
      deletePost: sl(),
    ),
  );
}

void _initChat() {
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      sl(),
      useDbNotificationTriggers: Env.useDbNotificationTriggers,
    ),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetChatsUseCase(sl()));
  sl.registerLazySingleton(() => GetChatByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetChatIdByMaintenanceRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetOrCreateChatUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkChatAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteChatsUseCase(sl()));
  sl.registerLazySingleton(() => WatchNewMessagesUseCase(sl()));
  sl.registerLazySingleton(() => WatchChatListChangesUseCase(sl()));
  sl.registerFactory(
    () => ChatListProvider(
      getChats: sl(),
      markChatAsRead: sl(),
      getOrCreateChat: sl(),
      deleteChats: sl(),
      watchChatListChanges: sl(),
    ),
  );
  sl.registerFactory(
    () => ConversationProvider(
      getChatById: sl(),
      getMessages: sl(),
      sendMessage: sl(),
      markChatAsRead: sl(),
      watchNewMessages: sl(),
    ),
  );
}

void _initMaintenance() {
  sl.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(
      sl(),
      useDbNotificationTriggers: Env.useDbNotificationTriggers,
    ),
  );
  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SubmitMaintenanceRequestUseCase(sl(), sl()));
  sl.registerFactory(
    () => MaintenanceRequestProvider(submitMaintenanceRequest: sl()),
  );
}

void _initNotifications() {
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => WatchNotificationsUseCase(sl()));
  sl.registerFactory(
    () => NotificationProvider(
      getNotifications: sl(),
      markNotificationAsRead: sl(),
      markAllNotificationsAsRead: sl(),
      deleteNotification: sl(),
      watchNotifications: sl(),
      getChatIdByMaintenanceRequest: sl(),
    ),
  );
}
